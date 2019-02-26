void serialEvent(Serial port) {
  try {
    String inData = port.readStringUntil('\n');
    inData = trim(inData);                 // cut off white space (carriage return)

    if (inData.charAt(0) == 'S') {           // leading 'S' means Pulse Sensor data packet
      inData = inData.substring(1);        // cut off the leading 'S'
      Sensor = int(inData);                // convert the string to usable int
    }
    if (inData.charAt(0) == 'B') {          // leading 'B' for BPM data
      inData = inData.substring(1);        // cut off the leading 'B'
      BPM = int(inData);                   // convert the string to usable int
      beat = true;                         // set beat flag to advance heart rate graph
      heart = 20;                          // begin heart image 'swell' timer
    }
    if (inData.charAt(0) == 'Q') {            // leading 'Q' means IBI data
      inData = inData.substring(1);        // cut off the leading 'Q'
      IBI = int(inData);                   // convert the string to usable int
    }
    if (inData.charAt(0) == 'U') {            // leading 'Q' means IBI data
      up = true;
    } else {
      up = false;
    }
    if (inData.charAt(0) == 'D') {            // leading 'Q' means IBI data
      down = true;
    } else {
      down = false;
    }
    if (inData.charAt(0) == 'L') {            // leading 'Q' means IBI data
      left = true;
    } else {
      left = false;
    }
    if (inData.charAt(0) == 'R') {            // leading 'Q' means IBI data
      right = true;
    } else {
      right = false;
    }
    if (inData.charAt(0) == 'P') {            // leading 'Q' means IBI data
      joystickPressed = true;
    } else {
      joystickPressed = false;
    }

    println(inData.charAt(0));
  } 
  catch(Exception e) {
    println(e.toString());
  }
}// END OF SERIAL EVENT
