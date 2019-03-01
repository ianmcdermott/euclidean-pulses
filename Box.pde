class Box {
  float x, y, w, h, o;
  boolean activated, playing, selected;
  color c;
  int channel, note;
  boolean noteIsOn = false;
  int onCount;
  int countLength = 1;
  float num;
  boolean played = false;
  int vo;
  boolean noteHasntPlayed;
  
  Box(float x_, float y_, float w_, float h_, color c_, int ch, int nt, float n_, int o_, int vo_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    c = c_;
    activated = false;
    playing = false;
    channel = ch;
    note = nt;
    o = o_;
    num = n_;
    vo = vo_;
    noteHasntPlayed = true;
  }

  void update() {
    if (noteHasntPlayed) {
      if (activated && playing) {
        mymididevice.sendNoteOn(channel, note, 90);
        noteIsOn = true;
        noteHasntPlayed = false;
      }
    }
    if (noteIsOn) {
      onCount++;
      if (onCount > countLength) {
        noteIsOn = false;
        onCount = 0;
        mymididevice.sendNoteOff(channel, note, 0);
      }
    }
    w = (noise((frameCount+vo*10+o*25)*.004)*100);
  }

  void display() {

    noStroke();
    ellipseMode(CENTER);
    if (activated && !playing) {
            fill(255-o*25, 0, 0);

    } else if (playing || playing && activated) {
      fill(255);
    } else {
            fill(0);

    }
    //if (activated) {
    //  fill(255-o*25, 230-o*25, 0);
    //} 

    ellipse(x+w/2, y+w/2, w-2, w-2);
    if (selected) {
      //strokeWeight(3);
      fill(255-o*20, 200-o*20, 210-o*20, 170);
      ellipse(x+w/2, y+w/2, w-2, w-2);
    }
  }
}
