class BeatSeq {
  Box[][] box = new Box[cols][rows];
  float eucAve = 5;
  float x, y, w, h;
  color c;
  int channel;
  int rotate = -1;
  int[] storedRhythm = new int[numbeats];

  int offset;
  boolean selected;


  BeatSeq(float x_, float y_, float w_, float h_, color c_, float off, int ch, int nt, int o_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    c = c_;
    offset = o_;
    channel = ch;
    selected = false;
    for (int i = 0; i < storedRhythm.length; i++) {
      storedRhythm[i] = 0;
    }

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        fill(0, 0, 244);
        box[i][j] = new Box(i*w+x, j*h+j*offset+y/1.5, w, h, c, ch, nt, j, offset, i);
      }
    }
  }

  void resetNHP() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        box[i][j].noteHasntPlayed = true;
      }
    }
  }
  
  void update(int playh, int fc) {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        int index = i+j*cols;
        int count = 0;

        if (storedRhythm[index] == 1) {
          box[i][j].activated = true;
        } else {
          box[i][j].activated = false;
        }

        box[i][j].update();

        if (selected) {
          box[i][j].selected = true;
        } else {
          box[i][j].selected = false;
        }
      }
    }
  }

  void updateScale(int newNote){
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {   
        box[i][j].note = newNote;
      }
    }
  }
  
  void play(int fc) {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (i+j*cols == fc) {
          box[i][j].playing = true;
        } else {
          box[i][j].playing = false;
        }
      }
    }
  }

  void display() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        pushMatrix();
        translate(0, j*height/rows-padding*j*2);
        box[i][j].display();
        popMatrix();
      }
    }
  }

  void savePulse(int bpm) {
    euclid(numbeats, bpm, rotate);
  }

  //calculate a euclidean rhythm
  void euclid(int steps, int pulses, int rotate) {
    print("Create new euclidean rhythm \n");
    print("Steps", steps, "Pulses", pulses, "Rotate", rotate, "\n");
    //rotate += 1;
    //rotate %= steps;
    clearArray(); //empty the array
    int bucket = 0;

    //fill track with rhythm
    for (int i=0; i< steps; i++) {
      bucket += pulses;
      if (bucket >= steps) {
        bucket -= steps;
        storedRhythm = append( storedRhythm, 1);
      } else {
        storedRhythm = append( storedRhythm, 0);
      }
    }
rotateSeq( steps, rotate);
    //rotate
    //if (rotate > 0) rotateSeq( steps, rotate);
  }

  //rotate a sequence
  void rotateSeq( int steps, int rotate) {
    int[] output  = new int[steps];
    int val = steps - rotate;
    for (int i=0; i<storedRhythm.length; i++) {
      output[i] = storedRhythm[ Math.abs( (i+val) % storedRhythm.length) ];
    }
    storedRhythm =  output;
  }

  void clearArray() {
    while (storedRhythm.length > 0) {
      storedRhythm = shorten(storedRhythm);
    }
  }

  //void clearArray() {
  // for (int i = 0; i < cols; i++) {
  //   for (int j = 0; j < rows; j++) {
  //     box[i][j].played = false;
  //   }
  // }
  //}
}