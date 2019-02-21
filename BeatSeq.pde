class BeatSeq {
  Box[] box = new Box[160];
  float eucAve;
  float x, y, w, h;
  int o;
  boolean selected;
  
  BeatSeq(float x_, float y_, float w_, float h_, int offset) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    o = offset;
    selected = false;
    //for (int i = 0; i < cols; i++) {
    //  float v = floor(i/53.0);
    //  println(v);
    int yoff = 0;
    for (int i = 0; i < box.length; i++) {
      if ((i > 0) && i % 53 == 0) yoff++;
      box[i] = new Box(w*(i % 53), y+yoff*int(height/rows), w, h/8, o, i);
    }
    //}

    //    for (int i = 0; i < box.length; i++) {
    //      box[i] = new Box(x, y, w, h, o);
    //    }
  }

  int gcd(int a, int b) {
    if (b != 0) {
      return gcd(b, a % b);
    } else {
      return a;
    }
  }

  void euclideanDistribution() {
    //clear boxes previous state
    for (int i = 0; i < box.length; i++) {
      box[i].activated = false;
    }
    int myGCD = gcd(numbeats, BPM);
    int count = 0;
    for (int i = 0; i < box.length; i++) {
      if (count == 0) {
        box[i].activated = true;
      }
      count++;
      if (count > myGCD) count = 0;
    }
  }

  void display() {
    for (int i = 0; i < box.length; i++) {
      box[i].display();
    }
  }

  void update(int playh, int fc) {
    for (int i = 0; i < box.length; i++) {
      if (playhead == i) {
        box[i].playing = true;
      } else {
        box[i].playing = false;
      }
      box[i].update(fc);
      if (selected) {
        box[i].selected = true;
      } else {
        box[i].selected = false;
      }
    }
  }

  void clear() {
    for (Box b : box) {
      b.played = false;
    }
  }
}
