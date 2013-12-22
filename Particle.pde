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

