//to do 
//optimize boids for regional crowfollow
//optimize boids to only detect a chunk of the array list of points
import processing.serial.*;  // serial library lets us talk to Arduino
import rwmidi.*;  

//Modes:
int[] ionian = {0, 2, 4, 5, 7, 9, 11, 12}; 
int[] dorian = {0, 2, 3, 5, 6, 8, 11, 12};
int[] phrygian = {0, 1, 3, 5, 6, 10, 11, 12};
int[] lydian = {0, 2, 4, 7, 6, 8, 9, 12};
int[] mixolydian = {0, 2, 4, 5, 6, 8, 11, 12};
int[] aeolian = {0, 2, 3, 5, 6, 10, 11, 12};
int[] locrian = {0, 1, 3, 5, 7, 10, 11, 12};
int pulseCount = 0;
IntList scale;
int tonic = 70;


boolean prevThreshhold = false;
//Sprite
Wings wings;
PImage[] wingImages;
int imageCount = 119;
int heartbeat;
int w = 700;
int cols;
int rows;
float d = w-10;
float r = d/2; 
float angle = 0;
float strokeW = 1;
float angleRes = .0007;
Guide[] vertGuides;
Guide[] horizGuides;
Curve[][] curves;
int phaseX = 5;
int phaseY = 0;
int threshhold = 550;
boolean beat1 = true;


int newLength =0;
float osc1 = 60;
float osc2 = 60;
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
boolean boidsOn = false;
boolean flockingOn = true;
boolean pathFollow = false;

int textAlpha = 0;
boolean textAlphaIncrease = false;
int alphaCount = 0;
boolean startAlphaCount = false;

String pulseText1 = "";
String pulseText2 = "";
int noteLag = 0;
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

ArrayList <Pulse> pulses;

//Ableton

byte mysysexmsg[] = {(byte)240, 127, 3, 4, 5, 6, (byte)247};

MidiOutput mymididevice; 
int mboolval;

void setup() {
  size(800, 800, P2D);
  //fullScreen(P2D);
  cols = 1;//width/w;
  rows = 1;//height/w;
  curves = new Curve[rows][cols];
  for (int i =0; i < cols; i++) {
    for (int j =0; j < rows; j++) {
      curves[j][i] = new Curve();
    }
  }
  wingImages = new PImage[imageCount];
  pulses = new ArrayList<Pulse>();
  loadWings();
  lbug = loadImage("bug-01.png");
  smooth();
  vertGuides = new Guide[rows];
  for (int i = 0; i < rows; i ++) {
    vertGuides[i] = new Guide(true);
  }
  horizGuides = new Guide[cols];

  for (int i = 0; i < cols; i ++) {
    horizGuides[i] = new Guide(false);
  }
  scale = new IntList();
  for (int i = 0; i < mixolydian.length; i++) {
    scale.append(ionian[i]);
  }

  //try {
  //  port = new Serial(this, Serial.list()[i], 115200);  // make sure Arduino is talking serial at this baud rate
  //  delay(1000);
  //  println(port.read());
  //  port.clear();            // flush buffer
  //  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
  //  serialPortFound = true;
  //}

  port = new Serial(this, "/dev/cu.usbmodem1411", 115200);

  //wings sprite
  wings = new Wings(imageCount);
  noCursor();


  // Show available MIDI output devices in console 
  MidiOutputDevice devices[] = RWMidi.getOutputDevices();

  for (int i = 0; i < devices.length; i++) { 
    println(i + ": " + devices[i].getName());
  } 

  // Currently we assume the first device (#0) is the one we want 
  mymididevice = RWMidi.getOutputDevices()[2].createOutput();
}

void draw() {
  println(pulseCount);
  if (serialPortFound) {
    // ONLY RUN THE VISUALIZER AFTER THE PORT IS CONNECTED

    // PRINT THE DATA AND VARIABLE VALUES
  } else { // SCAN BUTTONS TO FIND THE SERIAL PORT

    autoScanPorts();

    if (refreshPorts) {
      refreshPorts = false;
    }

    //Ableton
    println(heartbeat);
    if (heartbeat >= threshhold && !prevThreshhold) {
      newLength = 0;
      //noteLag++;
      //if (noteLag > 8) {
      mymididevice.sendNoteOn(pulseCount, tonic + scale.get(pulseCount), 90);
      prevThreshhold = true;
      //mboolval = 0;
      //noteLag = 0;
      //}
    } else if (heartbeat >= threshhold && prevThreshhold) {
      prevThreshhold = true;
    } else if (heartbeat < threshhold) {
      mymididevice.sendNoteOff(pulseCount, tonic + scale.get(pulseCount), 0);
      prevThreshhold = false;
      newLength++;
    }


    //Play the pulses
    //if (pulses != null) {
    //  for (Pulse p : pulses) {
    //    println("PL "+ p.pulseLength);
    //    //if (p.count % frameCount == 0) {
    //    //mymididevice.sendNoteOn(pulseCount, p.note, 1);
    //    //mymididevice.sendNoteOff(pulseCount, p.note, 0);
    //    //mboolval = 0;
    //    //if ( p.pulseLength % frameCount  == 0) {

    //    //  mymididevice.sendNoteOn(pulseCount, p.note, 90);
    //    //  mymididevice.sendNoteOff(pulseCount, p.note, 0);
    //    //}
    //    p.startNote(pulseCount);
    //    p.stopNote(pulseCount);
    //    //}
    //    //p.playBeat(pulseCount);
    //    pulseCount++;
    //    p.update();
    //    if(frameCount % p.pulseLength == 0) p.reset();
    //  }
    //  //update the counts on each pulse
    //}
    background(0);
    stroke(255);
    noFill();

    fill(200, 255, 255, textAlpha);
    textSize(150);
    textAlign(LEFT);
    text(pulseText1, 80, height/2); 
    textAlign(RIGHT);
    text(pulseText2, width-80, height/2); 

    //horiz
    for (int i = 0; i < cols; i ++) {
      horizGuides[i].update(osc1);//i+phaseX);
      horizGuides[i].display();

      for (int j = 0; j < rows; j++) {
        curves[j][i].setX(horizGuides[i].cx+horizGuides[i].x);
      }
    }
    //vert
    for (int i = 0; i < rows; i ++) {
      vertGuides[i].update(osc2);//i);
      vertGuides[i].display();

      for (int j = 0; j < cols; j++) {
        curves[i][j].setY(vertGuides[i].cy+vertGuides[i].y);
      }
    }

    for (int j =0; j < rows; j++) {
      for (int i =0; i < cols; i++) {
        curves[j][i].addPoint(frameCount);
        curves[j][i].show(frameCount+i+j);
      }
    }

    angle-= angleRes;

    if (angle < -TWO_PI) {
      for (int j = 0; j < rows; j++) {
        for (int i = 0; i < cols; i++) {
          curves[j][i].reset();
        }
      }
      angle = 0;
    }

    checkPulse();
  }

  if (textAlphaIncrease) {
    textAlpha++;
  }

  if (textAlpha >= 150) {
    textAlphaIncrease = false;
  }

  if (textAlphaIncrease == false && startAlphaCount) {
    alphaCount++;
    if (alphaCount >= 30) {
      textAlpha--;
      if (textAlpha <= 0) {
        textAlpha = 0;
        alphaCount = 0;
        startAlphaCount = false;
      }
    }
  }
}

void keyPressed() {
  if (key == 'p' || key == 'P') particlesOn = !particlesOn;
  if (key == 'l' || key == 'L') lissalines = !lissalines;
  if (key == 'd' || key == 'D') debug = !debug;
  if (key == 'f' || key == 'F') fractalsOn = !fractalsOn;
  if (key == 'b' || key == 'B') boidsOn = !boidsOn;
  if (key == 's' || key == 'S') springsOn = !springsOn;
  if (key == 'f' || key == 'F') {
    flockingOn = !flockingOn;
    pathFollow = !pathFollow;
  }
  if (key == CODED) {
    if (keyCode == RIGHT) {
      
    }
  }
  if (key == 'c' || key == 'C') clearVisuals();
  if (key == 'q') {
    textAlphaIncrease = true;
    if (beat1) {
      count1 = 0;
      startCount1 = true;
    } else {
      count2 = 0;
      startCount2 = true;
    }

    flockingOn = true;
  }
}

void keyReleased() {
  if (key == 'q') {
    pulseCount++;
    if (pulseCount > scale.size()-1) {
      pulseCount = 0;
    }
    startCount1 = false;
    startCount2 = false;
    curves[0][0].reset();
    beat1 = !beat1;
    startAlphaCount = true;
    flockingOn = false;
    pulses.add(new Pulse(newLength, 70+scale.get(scale.size()-1)));
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
void clearVisuals() {
  debug = false;
  lissalines = false;
  particlesOn = false;
  fractalsOn = false;
  springsOn = false;
  boidsOn = false;
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

void loadWings() {
  for (int i = 0; i < imageCount; i++) {
    // Use nf() to number format 'i' into four digits
    String filename = "data/lighteningbug_" + nf(i, 5) + ".png";
    //wImage = loadImage(filename);
    wingImages[i] = loadImage(filename);
  }
}
