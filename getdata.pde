processing.data.Table lyrics;
int lyricindex = 0;
void loadLyrics() {
  lyrics = loadTable("arabic.csv", "header");
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

