class Box {
  float x, y, w, h, o;
  boolean activated;
  boolean playing;
  boolean played = false;

  Box(float x_, float y_, float w_, float h_, int o_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    o = o_;
  }

  void display() {
    if (playing) {
      fill(255);
      stroke(255, 0, 0);
      rect(x, y, w, h);
    } else if (activated) {
      fill(0, 255-o*31, 0);
      stroke(255);
      rect(x, y, w, h);
    } else {
      fill(255-o*31, 0, 0);
      stroke(255);
      rect(x, y, w, h);
    }
  }

  void update() {
    if (!played) {
      if (activated && playing) {
        mymididevice.sendNoteOn(0, tonic + ionian[int(o)], 90);
        println("hit");
        played = true;
      }
    } else {
      mymididevice.sendNoteOff(0, int(tonic + ionian[int(o)]), 90);
    }
  }
}
