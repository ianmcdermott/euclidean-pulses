class Pulse {
  int count;
  int note = 70;
  int pulseLength;

  Pulse(int pl, int n) {
    //int note = 70;
    pulseLength = pl;
    note = n;
  }

  void update() {
    count++;
    //if (count % pulseLength == 0) reset();
  }

  void reset() {
    count = 0;
  }

  void startNote(int index) {
    if ( count % frameCount  == 0) {
      mymididevice.sendNoteOn(index, note, 90);
    }
  }

  void stopNote(int index) {
    if ( count % frameCount  == 0) {
      mymididevice.sendNoteOff(index, note, 0);
    }
    mboolval = 0;
  }
}