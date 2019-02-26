//to do 
//optimize boids for regional crowfollow
//optimize boids to only detect a chunk of the array list of points
import processing.serial.*;  // serial library lets us talk to Arduino
import rwmidi.*;  // For Ableton

//ArrayList<boolean> rhythm = new ArrayList<boolean>();
int pauses, per_pulse, remainder, steps, pulses, noskip, skipXTime;
boolean switcher;
//Sprite
PImage[] wingImages;
int imageCount = 119;
float padding;

float angle = 0;
float strokeW = 1;
float angleRes = .0007;
int playhead = 0;

BeatSeq[] beatsequences = new BeatSeq[8];
float tempo = 120;
boolean beat1 = true;

float osc1 = 50;
float osc2 = 50;
int count1 = 0;
int count2 = 0;

boolean pulseOn = false;
boolean startCount1 = false;
boolean startCount2 = false;

boolean joystickPressed, up, down, left, right;

PImage lbug;
//boolean osc = true;

boolean debug = false;
boolean lissalines = false;
boolean particlesOn = false;
boolean fractalsOn = false;
boolean springsOn = false;
boolean boidsOn = true;
boolean flockingOn = true;
boolean pathFollow = false;
int seqIndex = 0;

int textAlpha = 0;
boolean textAlphaIncrease = false;
int alphaCount = 0;
boolean startAlphaCount = false;

String pulseText1 = "";
String pulseText2 = "";

Serial port;

//Modes:
int[] ionian = {0, 2, 4, 5, 7, 9, 11, 12}; 
int[] dorian = {0, 2, 3, 5, 7, 9, 10, 12};
int[] phrygian = {0, 1, 3, 5, 7, 8, 10, 12};
int[] lydian = {0, 2, 4, 6, 7, 9, 11, 12};
int[] mixolydian = {0, 2, 4, 5, 7, 9, 10, 12};
int[] aeolian = {0, 2, 3, 5, 7, 8, 10, 12};
int[] locrian = {0, 1, 3, 5, 6, 8, 10, 12};
int root = 60;

int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 490;
int PulseWindowHeight = 512;
int BPMWindowWidth = 180;
int BPMWindowHeight = 340;
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced

// SERIAL PORT STUFF TO HELP YOU FIND THE CORRECT SERIAL PORT
String serialPort;
String[] serialPorts = new String[Serial.list().length];
boolean serialPortFound = false;
int numPorts = serialPorts.length;
boolean refreshPorts = false;
float wave;

int numbeats = 160;
int   cols = 53;//width/w;
int  rows = 3;//height/w;
private float w;
private float h;

int playRate = 0;
MidiOutput mymididevice; 
int mboolval;

void setup() {
  //size(2000, 1200, P2D);
  fullScreen(P2D);
  w = width/float(cols);
  padding = height/50;
  h = height/rows-padding*rows;

  for (int i = 0; i < beatsequences.length; i++) {
    beatsequences[i] = new BeatSeq(0, i*h/8+padding, w, h/8, color(int(255/beatsequences.length)*i, 
      0, 0), h+padding, i, root+ ionian[i], i);
  }
  //smooth();
  port = new Serial(this, "/dev/cu.usbmodem1431", 115200);
  noCursor();
  //frameRate(tempo/60);

  ///////// Ableton /////////
  // Show available MIDI output devices in console 
  MidiOutputDevice devices[] = RWMidi.getOutputDevices();

  for (int i = 0; i < devices.length; i++) { 
    println(i + ": " + devices[i].getName());
  } 

  // Currently we assume the first device (#0) is the one we want 
  mymididevice = RWMidi.getOutputDevices()[2].createOutput();
}

void draw() {
  background(0);
  //updatePlayhead();

  if (serialPortFound) {
    // ONLY RUN THE VISUALIZER AFTER THE PORT IS CONNECTED

    // PRINT THE DATA AND VARIABLE VALUES
  } else { // SCAN BUTTONS TO FIND THE SERIAL PORT

    autoScanPorts();

    if (refreshPorts) {
      refreshPorts = false;
    }
  }
  //stroke(255);
  //fill(0, 255, 0);
  ////padding rects
  //for (int j = 0; j < rows+1; j++) {
  //  rect(0, h*j + padding*j, width, padding);
  //}

  stroke(255);
  fill(255, 0, 0);

  for (int i = 0; i < beatsequences.length; i++) {
    pushMatrix();
    translate(0, h/16);
    beatsequences[i].play(playRate % 160);

    //beatsequences[i].update(frameCount);
    beatsequences[i].update(playhead, frameCount);

    beatsequences[i].display();
    if (i == seqIndex) {
      beatsequences[i].selected = true;
    } else {
      beatsequences[i].selected = false;
    }


    popMatrix();
  }

  ///// Text display /////

  if (textAlphaIncrease) {
    textAlpha+= 10;
  }

  if (textAlpha >= 150) {
    textAlphaIncrease = false;
  }

  if (textAlphaIncrease == false && startAlphaCount) {
    alphaCount++;
    if (alphaCount >= 30) {
      textAlpha-= 10;
      if (textAlpha <= 0) {
        textAlpha = 0;
        alphaCount = 0;
        startAlphaCount = false;
      }
    }
  }

  stroke(255);
  fill(200, 255, 255, textAlpha);
  textSize(150);
  textAlign(CENTER);
  text(pulseText1, width/2, height/2+75);

  if (frameCount*120 % 1000/(tempo/120) == 0) {

    playRate++;
  }
  
  checkJoystick();
}

void checkJoystick() {
  if (down) {
    seqIndex++;
    if (seqIndex > beatsequences.length-1) {
      seqIndex = 0;
    }
  }
  if (up) {
    seqIndex--;

    if (seqIndex < 0) {
      seqIndex = beatsequences.length-1;
    }
  }
  if (right) {
    tempo+= 40;
    if (tempo > 2600) tempo = 2600;
  }
  if (left) {
    tempo-= 40;
    if (tempo < 60) tempo = 60;
  }
  if (!joystickPressed) {
    textAlphaIncrease = true;
    checkPulse();
    startCount1 = false;
    startCount2 = false;
    println("BPM is "+BPM);
    beatsequences[seqIndex].savePulse(BPM);
    beat1 = !beat1;
    startAlphaCount = true;
    seqIndex++;
    if (seqIndex > beatsequences.length-1) {
      seqIndex = 0;
    }
  }
}

void keyPressed() {
  if (key == 'q') {
    textAlphaIncrease = true;
    checkPulse();
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == DOWN) {
      seqIndex++;
      if (seqIndex > beatsequences.length-1) {
        seqIndex = 0;
      }
    }
    if (keyCode == UP) {
      seqIndex--;

      if (seqIndex < 0) {
        seqIndex = beatsequences.length-1;
      }
    }
    if (keyCode == RIGHT) {
      tempo+= 40;
      if (tempo > 2600) tempo = 2600;
    }
    if (keyCode == LEFT) {
      tempo-= 40;
      if (tempo < 60) tempo = 60;
    }
  }
  if (key == 'q') {
    startCount1 = false;
    startCount2 = false;
    println("BPM is "+BPM);
    beatsequences[seqIndex].savePulse(BPM);
    beat1 = !beat1;
    startAlphaCount = true;
    seqIndex++;
    if (seqIndex > beatsequences.length-1) {
      seqIndex = 0;
    }
  }
}

void checkPulse() {
  osc1 = BPM;
  pulseText1 = str(BPM);
}


void getPulse() {
  while (pulseOn) {
    if (startCount1) count1++;
    else if (startCount2) count2++;
    //}
    //return count;
  }
}

void autoScanPorts() {
  if (Serial.list().length != numPorts) {
    if (Serial.list().length > numPorts) {
      println("New Ports Opened!");
      println(Serial.list());
      int diff = Serial.list().length - numPorts;  // was serialPorts.length
      serialPorts = expand(serialPorts, diff);
      numPorts = Serial.list().length;
    } else if (Serial.list().length < numPorts) {
      println("Some Ports Closed!");
      numPorts = Serial.list().length;
    }
    refreshPorts = true;
    return;
  }
}

void resetDataTraces() {
  for (int i=0; i<rate.length; i++) {
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window
  }
  for (int i=0; i<RawY.length; i++) {
    RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
}

void updatePlayhead() {
  //if (frameCount > 0) {
  println(60/tempo);
  if ((frameCount % int((60/tempo)*60)) == 0) {
    playhead++;
    for (BeatSeq bs : beatsequences) {
      bs.clearArray();
    }
  } 
  if (playhead > numbeats) playhead = 0;
  //}
}
