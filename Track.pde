class Track {
  ArrayList<PVector> points;
  float radius;
  boolean revDir;
  ArrayList<PVector> offsetPts;

  Track(ArrayList<PVector> pts) {
    radius = 3;
    points = pts; 
    revDir = true;
  }

  void update(ArrayList<PVector> pts) {
    points = pts;
  }
}