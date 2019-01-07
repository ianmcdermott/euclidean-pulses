//to do 
//optimize boids for regional crowfollow
//optimize boids to only detect a chunk of the array list of points
import processing.serial.*;  // serial library lets us talk to Arduino

//Sprite
PImage[] wingImages;
int imageCount = 119;

float padding;

float angle = 0;
float strokeW = 1;
float angleRes = .0007;

BeatSeq[] beatsequences = new BeatSeq[8];

boolean beat1 = true;

float osc1 = 50;
float osc2 = 50;
int count1 = 0;
int count2 = 0;

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
float w;
float h;

float tempo = 120;
int playhead = 0;
void setup() {
  //size(2000, 1200, P2D);
  fullScreen(P2D);
  w = width/float(cols);
  h = height/rows-padding*rows;
  padding = height/50;
  for (int i = 0; i < beatsequences.length; i++) {
    beatsequences[i] = new BeatSeq(0, padding+h/8*i, w, h, i);
  }
  smooth();
  port = new Serial(this, "/dev/cu.usbmodem1431", 115200);
  noCursor();
}

void draw() {
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
  for (int j = 0; j < rows+1; j++) {
    rect(0, h*j + padding*j, width, padding);
  }

  fill(200, 255, 255, textAlpha);
  textSize(150);
  textAlign(LEFT);
  text(pulseText1, 80, height/2); 
  textAlign(RIGHT);
  text(pulseText2, width-80, height/2);

  for (int i = 0; i < beatsequences.length; i++) {
    //for (int y = 0; y < beatsequences.length; y++) {
    beatsequences[i].display();
    beatsequences[i].update(playhead);

    //}
  }
}

void updatePlayhead() {
  //if (frameCount > 0) {
    if ((frameCount % int((60/tempo)*60)) == 0) playhead++;
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
}


void keyReleased() {
  if (key == 'q') {
    startCount1 = false;
    startCount2 = false;

    beat1 = !beat1;
    startAlphaCount = true;
    flockingOn = false;
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
