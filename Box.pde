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
  int[] melodicNote = new int[12];
  float selectWidth;

  Box(float x_, float y_, float w_, float h_, color c_, int ch, int nt, float n_, int o_, int vo_) {
    x = x_;
    y = y_;
    w = w_;
    selectWidth = w;
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
        // send Rhythmic note
        mymididevice.sendNoteOn(channel, channel, 127);
        println(channel);
        // Send Melodic Note
        mymididevice.sendNoteOn(13, note, int(random(70, 127)));
        noteIsOn = true;
        noteHasntPlayed = false;
      }
    } 
    if (noteIsOn) {
      onCount++;
      if (onCount > countLength) {
        noteIsOn = false;
        onCount = 0;
        mymididevice.sendNoteOff(channel, channel, 0);
        mymididevice.sendNoteOff(13, note, 0);
      }
    }
    w = (noise((frameCount+vo*10+o*25)*.004)*100);
    selectWidth = w;
  }

  void display() {

    noStroke();
    ellipseMode(CENTER);
    if (activated && !playing) {
      fill(255-o*20, 0, 0);
    } else if (playing || playing && activated) {
      fill(255);
    } else {
      fill(0);
    }
    ellipse(x+w/2, y+w/2, w, w);
    if (selected) {
      int alphaChange = int(map(Sensor, 300, 700, 0, 60));
      fill(255-o*20, 200-o*20, 210-o*20, 170-alphaChange);
      if(Sensor > 300) selectWidth += map(Sensor, 300, 700, 0, 20); 
      ellipse(x+w/2, y+w/2, selectWidth, selectWidth);
    }
        //ellipse(x+w/2, y+w/2, w, w);

  }
}
