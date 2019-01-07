class Box {
  float x, y, w, h, o;
  boolean activated;
  boolean playing;

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
      fill(0, 255, 0);
      stroke(255);
      rect(x, y, w, h);
    } else {
      fill(255-o*31, 0, 0);
      stroke(255);
      rect(x, y, w, h);
    }
  }
}
