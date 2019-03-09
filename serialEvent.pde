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
      heart = 20;           // begin heart image 'swell' timer
      bpmStoreCount++;      // Up the bpmStore Count so we can check how long it's been since a big change in pulse
    }
    if (inData.charAt(0) == 'Q') {            // leading 'Q' means IBI data
      inData = inData.substring(1);        // cut off the leading 'Q'
      IBI = int(inData);                   // convert the string to usable int
    }
    if (inData.charAt(0) == 'U') {            // leading 'Q' means IBI data
      up = true;
      upCount++;
    } else {
      up = false;
      upCount = 0;
    }
    if (inData.charAt(0) == 'D') {            // leading 'Q' means IBI data
      down = true;
      downCount++;
    } else {
      down = false;
      downCount = 0;
    }
    if (inData.charAt(0) == 'R') {            // leading 'Q' means IBI data
      left = true;
      leftCount++;
    } else {
      left = false;
      leftCount = 0;
    }
    if (inData.charAt(0) == 'L') {            // leading 'Q' means IBI data
      right = true;
      rightCount++;
    } else {
      right = false;
      rightCount = 0;
    }
    if (inData.charAt(0) == 'J') {            // leading 'Q' means IBI data
      pressedCount++;
      if (pressedCount > 5)       joystickPressed = true;
      pressedLock = false;
      println(pressedCount);
    } else {
      joystickPressed = false;
      pressedCount--;
      if (pressedCount <= 5) {
        pressedCount = 0;
        pressedLock = true;
      }
      blockPress = true;
    }
  } 
  catch(Exception e) {
    println(e.toString());
  }
}// END OF SERIAL EVENT