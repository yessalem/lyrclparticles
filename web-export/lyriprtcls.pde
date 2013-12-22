import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;


Minim minim;
AudioPlayer player;
AudioSource in;
BeatDetect beat;
int buffersize;
float leftbuffer[], rightbuffer[];
float mixbuffer[];
float leftvolume, rightvolume;
float damper = 0.8;

ArrayList<Particle> particles, movers, extras;
ArrayList<Attractor> attractors;

String musicfile;

RFont font; 
RGroup group;
RPoint[] points;

String lyric; 
int timingindex = 1;
int[] timing;

void setup() {
  size(1300, 650, OPENGL);
  //size(1440, 900, OPENGL);
  background(0);

  loadLyrics();
  timing = getTimingData();

  minim = new Minim(this);
  musicfile = "04 True Loves.mp3";
  //musicfile = "spiller.mp3";
  //musicfile = "06 - Aurora Gone.mp3";
  buffersize = 1024;

  player = minim.loadFile(musicfile, buffersize);
  player.play();

  in = (AudioSource)player;
  getMusicData();
  makeParticles();
  drawParticles();


  RG.init(this);
  font = new RFont("NeutraText-Bold.ttf", 170, CENTER);

  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  lyric = getNextLyric();
  beat = new BeatDetect();
  beat.setSensitivity(10);

  //movers = new ArrayList<Particle>();

  makeMoverParticles();
  drawMovers();
}

void draw() {
  background(0);

  //moveThroughLyrics();
  int now = millis();
  if ((timingindex <10) && (now >= timing[timingindex])) {
    lyric = getNextLyric();
    timingindex++;
  }



  group = font.toGroup(lyric);
  group = group.toPolygonGroup();

  points = group.getPoints();
  createAttractorParticles();
  setAttraction();

  getMusicData();
  drawMovers();
  drawParticles();
  if (extras != null) {

    setExtrasAttraction();
    steerExtraParticles();
    drawExtras();
  }

  noFill();
  stroke(170, 170, 0);
  beginShape();
  for (int i=0; i<attractors.size(); i++) {
    //attractors.get(i).draw();
    //vertex(attractors.get(i).location.x, attractors.get(i).location.y);
    //println("drew attractor " + i + " at " + attractors.get(i).location.x + " and " + attractors.get(i).location.y);
  }
  endShape();

  if (frameCount > 5) {
    varyParticleSizeToWaveForm();
    //applyForceAccordingToWaveForm();
    steerParticles();
  }
  beat.detect(leftbuffer);
  if (beat.isOnset()) {
    //    noStroke();
    //    fill(255, 20, 147);
    //    //fill(250, 124, 7, 200);
    //    ellipseMode(CENTER);
    //    ellipse(100, height-100, 50, 50);


    for (int i = 0; i < movers.size(); i++) {
      movers.get(i).expand();
      //movers.get(i).retract();
    }

    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).expand();
      //movers.get(i).retract();
    }

    if (now  >= /*timing[4] + 2000*/ 117489) {

      //background(255, 20, 147);
      //      if(extras == null) extras = new ArrayList<Particle>();
      //      for (int i = 0; i <= 4; i++) {
      //        Particle prt = new Particle();
      //        prt.col = color(250, 124, 7, 150);
      //        prt.size = 20;
      //        
      //        extras.add(prt);
      //      }

      for (int i = 0; i < particles.size(); i++) {
        color temp[] = { 
          color(247, 207, 10, random(170, 200)), 
          color(252, 231, 13, random(170, 200)), 
          color(175, 230, 41, random(170, 200)), 
          color(255, 20, 147, random(170, 200)), 
          color(48, 196, 201, random(170, 200))
        };
        particles.get(i).colarray = temp;
        particles.get(i).randomizeColor();
      }
    }
    
    if(now >= timing[4]){
     applyForceAccordingToWaveForm(); 

    }
    
    if (now  >= timing[7]) {

      for (int i = 0; i < movers.size(); i++) {
        color temp[] = { 
          color(247, 207, 10, random(100, 120)), 
          color(252, 231, 13, random(100, 120)), 
          color(175, 230, 41, random(100, 120)), 
          color(255, 20, 147, random(100, 120)), 
          color(48, 196, 201, random(100, 120))
        };
        movers.get(i).colarray = temp;
        movers.get(i).randomizeColor();
      }
    }
  }


  fill(0);
  text(millis(), width-100, height-100); 
  if (millis() == 63000) {

    for (int i=0; i<particles.size(); i++) {
      //particles.get(i).maxforce = 10;
      //particles.get(i).maxspeed = 15;
    }
  }
}

void getMusicData() {
  if (leftbuffer == null) {
    buffersize = in.bufferSize();
    //print(buffersize);
    leftbuffer = new float[buffersize];
    rightbuffer = new float[buffersize];
    mixbuffer = new float[buffersize];
  }

  for (int i = 0; i < buffersize; i++) {
    leftbuffer[i] = in.left.get(i);
    //println(in.left.get(i));
    rightbuffer[i] = in.right.get(i);
    //println(in.right.get(i));

    mixbuffer[i] = in.left.get(i)/in.left.level();
    //println(in.right.get(i));
  }
}

void makeParticles() {
  particles = new ArrayList<Particle>();

  for (int i = 0; i < mixbuffer.length/2  ; i++) {
    //float leftwaveformvalue = leftbuffer[i];
    float xleft = random(0, width);
    float yleft = random(0, height);

    particles.add(new Particle());
  }
}

void makeMoverParticles() {

  movers = new ArrayList<Particle>();

  for (int i = 0; i < mixbuffer.length/2  ; i++) {
    //float leftwaveformvalue = leftbuffer[i];
    float xleft = random(0, width);
    float yleft = random(0, height);

    movers.add(new Particle());
  }

  for (int i = 0; i < movers.size(); i++) {


    //movers.get(i).col = color(255, random(50, 100));
    color temp[] = { 
      color(247, 207, 10, random(170, 200)), 
      color(252, 231, 13, random(170, 200)), 
      color(175, 230, 41, random(170, 200)), 
      color(255, 20, 147, random(170, 200))
    };
    movers.get(i).colarray = temp;

    movers.get(i).col = color(247, 207, 10, random(50, 120));
    movers.get(i).size = random(10, 15);
  }
}

void applyForceAccordingToWaveForm() {
  for (int i = 0; i < movers.size(); i++) {
    float mixwaveformvalue = mixbuffer[i];
    movers.get(i).applyForce(new PVector(map(mixwaveformvalue, -1, 1, -10, 10), 0));
    //println(leftwaveformvalue);
  }
}

void varyParticleSizeToWaveForm() {
  for (int i = 0; i < particles.size(); i++) {
    float mixwaveformvalue = mixbuffer[i];
    float size = map(mixwaveformvalue, -1, 1, 5, 50);
    size = damper*size + (1-damper) * mixwaveformvalue * 50 +2;
    particles.get(i).size = size;

    //println(leftwaveformvalue);
  }
}

void varyParticleSizeToBeat() {
  for (int i = 0; i < movers.size(); i++) {
    float mixwaveformvalue = mixbuffer[i];
    float size = map(mixwaveformvalue, -1, 1, 5, 50);
    size = damper*size + (1-damper) * mixwaveformvalue * 50 +2;
    particles.get(i).size = size;

    //println(leftwaveformvalue);
  }
}

void createAttractorParticles() {
  attractors = new ArrayList<Attractor>();
  for (int i =0; i < points.length; i++) {
    Attractor temp = new Attractor();
    temp.location = new PVector(map(points[i].x, -500, 500, width/2-500, width/2+500), map(points[i].y, -150, 150, height/2-150, height/2+150));
    //temp.location = new PVector(width/2, height/2);
    attractors.add(temp);
    //println("attractor " + i + "'s x is at " + attractors.get(i).location.x + " and " + attractors.get(i).location.y);
  }
}

void drawParticles() {
  for (int i = 0; i < particles.size(); i++) {
    particles.get(i).run();
  }
}

void drawMovers() {
  for (int i = 0; i < movers.size(); i++) {
    movers.get(i).run();
    //movers.get(i).steer();
    //movers.get(i).shift();
  }
}

void drawExtras() {
  for (int i = 0; i < extras.size(); i++) {
    extras.get(i).run();
    extras.get(i).shift();
  }
}

void setAttraction() {
  for (int i = 0; i < particles.size(); i++) {
    //int index = int(random(0, attractors.size()-1));
    particles.get(i).assignTarget(attractors.get(i%attractors.size()));
    //particles.get(i).maxforce = 10/63000; 
    //println("attractor " + index + " was attached to particle " + i);
  }
}

void setExtrasAttraction() {
  for (int i = 0; i < extras.size(); i++) {
    //int index = int(random(0, attractors.size()-1));
    extras.get(i).assignTarget(attractors.get(i%attractors.size()));
    //particles.get(i).maxforce = 10/63000; 
    //println("attractor " + index + " was attached to particle " + i);
  }
}

void steerParticles() {
  for (int i =0; i < particles.size(); i++) {
    particles.get(i).steer();
  }
}

void steerExtraParticles() {
  for (int i =0; i < extras.size(); i++) {
    extras.get(i).steer();
  }
}


void keyPressed() {
  //lyric = getNextLyric();
  println(millis());
}

void moveThroughLyrics() {
  for (int i = 0; i < timing.length; i++) {
    if (frameCount == timing[i])  lyric = getNextLyric();
  }
}

class Attractor extends Particle {
  

  Attractor() {
    super();
    col = color(176, 230, 41);
    size = 20;
    alpha = 200;
  }
} 

class Particle {
  float size, newsize, oldsize;
  PVector location;
  PVector velocity;
  PVector acceleration;
  color col;
  color[] colarray = {
    color(252, 231, 13), color(175, 230, 41)
  };
  float alpha;
  float mass;
  Particle target;

  float maxspeed = 10;
  float maxforce = 5;
  //float damper = 0.8;
  int life;
  float noiseoffset;

  float jitter = 30;
  boolean drawinner = false;
  boolean expanded = false;

  Particle() {
    size = 5;
    location = new PVector(random(width), random(height));
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    //colorMode(HSB);
    col = color(252, 231, 13);
    col = color(175, 230, 41);
    int index = int(random(0, 2));
    col = colarray[index];
    //col = color(255, 20, 147);
    //colorMode(RGB);
    alpha = random(170, 200);
    mass = 100;
    life = 500;
    newsize = size * 10;
  }

  Particle(PVector location_, float size_) {
    size = size_;
    location = location_;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    colorMode(HSB);
    col = color(252, 231, 13);
    //col = color(255, 20, 147);
    colorMode(RGB);
    alpha = random(170, 200);
    mass = 100;
    life = 500;
    newsize = size * 10;
  }

  void moveColor() {
    colorMode(HSB);
    float huevalue = hue(col);
    huevalue = (huevalue+0.1);
    col = color(huevalue, saturation(col), brightness(col));
    colorMode(RGB);
  }

  void applyForce(PVector force_) {
    PVector newacceleration = PVector.div(force_, mass); 

    acceleration.add(newacceleration);
  }

  void steer(Particle target_) {
    PVector desiredvelocity = PVector.sub(target_.location, location);
    desiredvelocity.normalize();
    desiredvelocity.mult(maxspeed);

    PVector steeringforce = PVector.sub(desiredvelocity, velocity);
    steeringforce.limit(maxforce);
    applyForce(steeringforce);
  }

  void assignTarget(Particle target_) {
    target = target_;
  }

  void steer() {
    PVector modefiedlocation = new PVector(target.location.x, target.location.y);
    //println("passed modefiedlocation");

    PVector desiredvelocity = PVector.sub(modefiedlocation, location);
    //println("desired velocity before normalization: x=" + desiredvelocity.x + " y= " +  desiredvelocity.y);
    desiredvelocity.normalize();
    desiredvelocity.mult(0.75);

    //desiredvelocity.mult(maxspeed);
    //println("desired velocity after normalization: x=" + desiredvelocity.x + " y= " +  desiredvelocity.y);

    PVector steeringforce = PVector.sub(desiredvelocity, velocity);
    steeringforce.limit(maxforce);
    applyForce(steeringforce);

    //println("Steering at force  x= " + steeringforce.x + " y= " + steeringforce.y); //target.saySomething();
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    checkEdges();
  }

  void checkEdges() {

    if (location.x > width) location.x = 0; 
    else if (location.x < 0) location.x = width; 
    if (location.y > height) location.y = 0;
    else if (location.y < 0) location.y = height;
  }

  void run() {
    update();
    draw();
  }

  void draw() {
    size = damper*size + (1-damper)*size;
    
    if (drawinner) {
      //fill(0, 191, 255, alpha);
      //fill(250, 124, 7, alpha);
      //ellipse(location.x, location.y + jitter, size/4, size/4);
      //jitter = 60;
      drawinner = false;
    }
    //pushMatrix();
    //stroke(200);
    noStroke();
    fill(col, alpha);
    //translate(location.x, location.y/*, random(-1, 0)*/);
    //sphere(size/2);
    ellipseMode(CENTER);
    //ellipse(0, 0, size/2, size/2);
    ellipse(location.x, location.y + jitter, size/2, size/2);

    
    //popMatrix();

    //moveColor();
    if(expanded) retract();
  }
  
  void expand(){
    oldsize = size;
    size = newsize;
    expanded = true;
    
  }
  
  void retract(){
    size = oldsize;
    
  }
  
   void shift(){
    location.x = random(location.x-2, location.x+2);
    location.y = random(location.y-2, location.y+2);
    
  }
  
  void randomizeColor(){
    int colorindex = int(random(0, colarray.length));
    col = colarray[colorindex];
    
    
  }
}

processing.data.Table lyrics;
int lyricindex = 0;
void loadLyrics() {
  lyrics = loadTable("trueloves.csv", "header");
}

String getNextLyric() {
  TableRow row = lyrics.getRow(lyricindex); 
  String lyric = row.getString(1);
  lyricindex++;
  return lyric;
}

int[] getTimingData() {
  int[] timing = new int[lyrics.getRowCount()];

  for (int i = 0; i < lyrics.getRowCount(); i++) {

    TableRow row = lyrics.getRow(i);
    timing[i] = row.getInt(0);
    println(timing[i]);
  }
  
  return timing; 
}


int[] getFrameTimingData() {
  int[] timing = new int[lyrics.getRowCount()];

  for (int i = 0; i < lyrics.getRowCount(); i++) {

    TableRow row = lyrics.getRow(i);
    timing[i] = row.getInt(2);
    println(timing[i]);
  }
  
  return timing; 
}


