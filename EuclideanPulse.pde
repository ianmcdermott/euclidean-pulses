import processing.serial.*;  // serial library lets us talk to Arduino
import rwmidi.*;  

//Sprite
PImage[] wingImages;
int imageCount = 119;

float padding;

float angle = 0;
float strokeW = 1;
float angleRes = .0007;

BeatSeq[] beatsequences = new BeatSeq[8];

boolean beat1 = true;
int tonic = 70;

float osc1 = 50;
float osc2 = 50;
int count1 = 0;
int count2 = 0;
int seqIndex = 0;
boolean pulseOn = false;
boolean startCount1 = false;
boolean startCount2 = false;

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

int textAlpha = 0;
boolean textAlphaIncrease = false;
int alphaCount = 0;
boolean startAlphaCount = false;

String pulseText1 = "";
String pulseText2 = "";

Serial port;

int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
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

//Limit the number of beats to 160, may need to raise if you're taking the pulse of someone who's just run a mile, caffine addicts, etc
int numbeats = 160;
int   cols = 53;//width/w;
int  rows = 3;//height/w;
float w;
float h;

float tempo = 240;
int playhead = 0;
MidiOutput mymididevice; 

int[] scale = new int[8];
int[] ionian = {0, 2, 4, 5, 7, 9, 11, 12}; 
int[] dorian = {0, 2, 3, 5, 6, 8, 11, 12};
int[] phrygian = {0, 1, 3, 5, 6, 10, 11, 12};
int[] lydian = {0, 2, 4, 7, 6, 8, 9, 12};
int[] mixolydian = {0, 2, 4, 5, 6, 8, 11, 12};
int[] aeolian = {0, 2, 3, 5, 6, 10, 11, 12};
int[] locrian = {0, 1, 3, 5, 7, 10, 11, 12};
int[] percussion = {0, 1, 2, 3, 4, 5, 6, 7};

void setup() {
  //size(2000, 1200, P2D);
  fullScreen(P2D);
  w = width/float(cols);
  h = height/rows-padding*rows;
  padding = 0;//height/50;
  for (int i = 0; i < beatsequences.length; i++) {
    beatsequences[i] = new BeatSeq(0, padding+h/8*i, w, h, i);
  }
  smooth();
  port = new Serial(this, "/dev/cu.usbmodem1431", 115200);
  noCursor();

  // Show available MIDI output devices in console 
  MidiOutputDevice devices[] = RWMidi.getOutputDevices();

  for (int i = 0; i < devices.length; i++) { 
    println(i + ": " + devices[i].getName());
  } 

  // Currently we assume the first device (#0) is the one we want 
  mymididevice = RWMidi.getOutputDevices()[2].createOutput();
  smooth();
}

void draw() {
  background(0);
  updatePlayhead();
  if (serialPortFound) {
    // ONLY RUN THE VISUALIZER AFTER THE PORT IS CONNECTED

    // PRINT THE DATA AND VARIABLE VALUES
  } else { // SCAN BUTTONS TO FIND THE SERIAL PORT

    autoScanPorts();

    if (refreshPorts) {
      refreshPorts = false;
    }
  }
  stroke(255);
  fill(0, 255, 0);
  //padding rects
  //for (int j = 0; j < rows+1; j++) {
  //  rect(0, h*j + padding*j, width, padding);
  //}

  fill(200, 255, 255, textAlpha);
  textSize(150);
  textAlign(LEFT);
  text(pulseText1, 80, height/2); 
  textAlign(RIGHT);
  text(pulseText2, width-80, height/2);

  for (int i = 0; i < beatsequences.length; i++) {
    beatsequences[i].display();
    beatsequences[i].update(playhead, frameCount);
    if (i == seqIndex) {
      beatsequences[i].selected = true;
    } else {
      beatsequences[i].selected = false;
    }
  }
}

void updatePlayhead() {
  //if (frameCount > 0) {
  if ((frameCount % int((60/tempo)*60)) == 0) {
    playhead++;
    for (BeatSeq bs : beatsequences) {
      bs.clear();
    }
  } 
  if (playhead > numbeats) playhead = 0;
  //}
}

void keyPressed() {
  textAlphaIncrease = true;
  if (beat1) {
    count1 = 0;
    startCount1 = true;
  } else {
    count2 = 0;
    startCount2 = true;
  }

  if (key == '1')  scale = ionian;
  if (key == '2')  scale = dorian;
  if (key == '3')  scale = phrygian;
  if (key == '4')  scale = lydian;
  if (key == '5')  scale = mixolydian;
  if (key == '6')  scale = aeolian;
  if (key == '7')  scale = locrian;
  if (key == '8')  scale = percussion;


  if (key == CODED) {
    if (keyCode == UP) {
      seqIndex--;
      if (seqIndex < 0) {
        seqIndex = beatsequences.length-1;
      }
    } 
    if (keyCode == DOWN) {
      seqIndex++;
      if (seqIndex > beatsequences.length-1) {
        seqIndex = 0;
      }
    }
    if (keyCode == RIGHT) {
      tempo++;
      if (tempo > 250) {
        tempo = 250;
      }
    } 
    if (keyCode == DOWN) {
      tempo--;
      if (tempo < 40) {
        tempo = 40;
      }
    }
  }
}


void keyReleased() {
  if (key == 'q') {
    beatsequences[seqIndex].euclideanDistribution();
  }
}

void checkPulse() {
  if (startCount1) {
    count1++;
    osc1 = BPM;
    pulseText1 = str(BPM);
  } else if (startCount2) {
    count2++;
    osc2 = BPM;
    pulseText2 = str(BPM);
  } 
  //println("BPM: "+BPM);
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
