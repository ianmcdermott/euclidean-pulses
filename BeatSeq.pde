class BeatSeq {
  Box[] box = new Box[160];
  float eucAve;
  float x, y, w, h;
  int o;
  BeatSeq(float x_, float y_, float w_, float h_, int offset) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    o = offset;

    //for (int i = 0; i < cols; i++) {
    //  float v = floor(i/53.0);
    //  println(v);
    int yoff = 0;
    for (int i = 0; i < box.length; i++) {
      if ((i > 0) && i % 53 == 0) yoff++;
      box[i] = new Box(w*(i % 53), y+yoff*int(height/rows), w, h/8, o);
    }
    //}

    //    for (int i = 0; i < box.length; i++) {
    //      box[i] = new Box(x, y, w, h, o);
    //    }
  }

  void euclideanAverage(int bpm) {
  }

  void update() {
    for (int i = 0; i < box.length; i++) {
      if (i % eucAve == 0 && str(eucAve) != null) {
        box[i].activated = true;
      } else {
        box[i].activated = false;
      }
    }
  }

  void display() {
    for (int i = 0; i < box.length; i++) {
      box[i].display();
    }
  }

  void update(int playh) {
    for (int i = 0; i < box.length; i++) {
      if (playhead == i) {
        box[i].playing = true;
      } else {
        box[i].playing = false;
      }
    }
  }
}
