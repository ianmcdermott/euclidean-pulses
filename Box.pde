class Box {
  float x, y, w, h, o;
  boolean activated;
  boolean playing;
  boolean played = false;
  boolean selected;

  Box(float x_, float y_, float w_, float h_, int o_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    o = o_;
  }

  void display() {
    noStroke();
    //ellipseMode(CORNER);
    if (playing) {
      fill(255);
    } else {
      fill(255-o*25, 0, 0);
    }
    if (activated) {
      fill(255-o*25, 230-o*25, 0);
    } 
    ellipse(x+w/2, y+w/2, w-2, w-2);
    if (selected) {
      strokeWeight(3);
      fill(255-o*20, 200-o*20, 210-o*20, 170);

      ellipse(x+w/2, y+w/2, w-2, w-2);
    }
  }

  void update(int fc) {
    if (!played) {
      if (activated && playing) {
        mymididevice.sendNoteOn(0, tonic + scale[int(o)], 90);
        println("hit");
        played = true;
      }
    } else {
      mymididevice.sendNoteOff(0, int(tonic + scale[int(o)]), 90);
    }

    w += sin((2*o+fc)*.2)*1.5;
  }
}
