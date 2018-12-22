class Guide {
  float cy;
  float cx;

  float x ;
  float y ;
  boolean reversed;

  Guide(boolean rev) {
    reversed = rev;
  }
  void update(float i) {
    if (reversed) {
      cy = height/2; // w + i * w + w/2;
      cx = width/2; // w/2 - i*w;
    } else {
      cy = height/2; //w/2;
      cx = width/2; //w + i * w + w/2 - i*w;
    }

    x = r*cos(angle * (i+1) - HALF_PI);
    y = r*sin(angle * (i+1)  - HALF_PI);
  }
  
  void display() {
    if (debug) {

      strokeWeight(strokeW);
      stroke(255, 0, 0);
      ellipse(cx, cy, d, d);

      strokeWeight(strokeW*8);
      point(cx+x, cy+y);

      stroke(255, 50);
      strokeWeight(strokeW);
      if (reversed) {
        line(0, cy+y, width, cy+y);
      } else {
        line(cx+x, 0, cx+x, height);
      }
    }
  }
}