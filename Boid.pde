// The Boid class

class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int blink   = 0;
  float blinkOffset;
  PVector leader;
  float desiredseparation;
  float blinkDepth;
  float speed = 0;
  
  Boid(float x, float y, float _r, float ms, float mf, float bo, float bd) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(random(width), random(height));
    r = _r;
    maxspeed = ms;
    maxforce = mf;
    blinkOffset = bo;
    desiredseparation = r*4;
    blinkDepth  = bd;
  }

  void run(ArrayList<Boid> boids, int displayWingsFrame) {
    flock(boids);
    update();
    borders();
    render(displayWingsFrame);
    //leader = new PVector(curves[0][0].curr.x, curves[0][0].curr.y);

    blink = int(sin((blinkOffset*frameCount)*0.05)*100+blinkDepth);//*.25+.75;
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector folLead  = followLeader(new PVector(curves[0][0].curr.x, curves[0][0].curr.y));
    PVector fol = follow(curves[0][0].track);

    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    folLead.mult(.5);
    // Add the force vectors to acceleration
    applyForce(sep);

    if (pathFollow) {
      desiredseparation = r*2;
      applyForce(fol);
    } else {
      desiredseparation = r*10;
    }

    if (flockingOn) {
      applyForce(ali);
      applyForce(coh);
      // applyForce(folLead);
    }
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);


    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    speed = acceleration.mag()*3;

    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    //PVector lissajousTarget = new PVector(curves[0][0].curr.x, curves[0][0].curr.y);
    //PVector midPointTarget =     PVector.sub(lissajousTarget, target);

    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    //stroke(255, 0, 0);
    //line(target.x, target.y, position.x, position.y);
    desired.normalize();
    desired.mult(maxspeed);
    //Check for the Curve's leading point


    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render(int displayWingsFrame) {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up

    noStroke();
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    fill(255, 0, 0);
    //beginShape(TRIANGLES);
    //vertex(0, -r*2);
    //vertex(-r, r*2);
    //vertex(r, r*2);
    //endShape();
    colorMode(HSB, 100);
    fill(20, 100, 100-blink);
    ellipse(0, r*2, r*3, r*4);

    pushMatrix();
    scale(r*.075);
    translate(0, -50);
    wings.display(-100, 0, displayWingsFrame, velocity.mag());
    //image(lbug, 0, 0);
    popMatrix();

    popMatrix();
    colorMode(RGB, 255);
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {

    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    PVector lissajousTarget = new PVector(curves[0][0].curr.x, curves[0][0].curr.y);

    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }

  PVector follow(Track t) {
    PVector predict = velocity.get();
    predict.normalize();
    predict.mult(25);
    PVector predictLoc = PVector.add(position, predict);

    PVector normal = null;
    PVector target = null;
    float worldRecord = 1000000000;

    for (int i = 0; i < t.points.size (); i++) {
      // Look at a line segment
      PVector a = t.points.get(i);
      PVector b = t.points.get((i+1)%t.points.size()); // Note Path has to wraparound
      // Get the normal point to that line
      PVector normalPoint = getNormalPoint(predictLoc, a, b);
      PVector dir;
      // Check if normal is on line segment
      // If it's not within the line segment, consider the normal to just be the end of the line segment (point b)
      //if (da + db > line.mag()+1) {
      if (t.revDir) {
        dir = PVector.sub(b, a);

        if (normalPoint.x < min(a.x, b.x) || normalPoint.x > max(a.x, b.x) || normalPoint.y < min(a.y, b.y) || normalPoint.y > max(a.y, b.y)) {
          normalPoint = b.get();
          // If we're at the end we really want the next line segment for looking ahead
          a = t.points.get((i+1)%t.points.size());
          b = t.points.get((i+2)%t.points.size()); // Path wraps around
          dir = PVector.sub(b, a);
        }
      } else {
        dir = PVector.sub(a, b);

        if (normalPoint.x > max(b.x, a.x) || normalPoint.x < min(b.x, a.x) || normalPoint.y > max(b.y, a.y) || normalPoint.y < min(b.y, a.y)) {
          normalPoint = a.get();
          // If we're at the end we really want the next line segment for looking ahead
          a = t.points.get((i+2)%t.points.size());
          b = t.points.get((i+1)%t.points.size()); // Path wraps around
          dir = PVector.sub(a, b);
        }
      }
      // How far away are we from the path?
      float d = PVector.dist(predictLoc, normalPoint);
      // Did we beat the worldRecord and find the closest line segment?
      if (d < worldRecord) {
        worldRecord = d;
        normal = normalPoint;
        // Look at the direction of the line segment so we can seek a little bit ahead of the normal
        dir.normalize();
        // This is an oversimplification
        // Should be based on distance to path & velocity
        dir.mult(25);
        target = normal.get();
        target.add(dir);
      }
    }

    // Only if the distance is greater than the path's radius do we bother to steer
    if (worldRecord > t.radius/2) {
      return seek(target);
    } else {
      return new PVector(0, 0);
    }
  }

  PVector getNormalPoint(PVector p, PVector a, PVector b) {
    PVector ap = PVector.sub(p, a);
    PVector ab = PVector.sub(b, a);

    ab.normalize();
    ab.mult(ap.dot(ab));
    PVector normalPoint = PVector.add(a, ab);

    return normalPoint;
  }

  PVector followLeader (PVector target) {
    PVector lissajousTarget = new PVector(curves[0][0].curr.x, curves[0][0].curr.y);

    //float neighbordist = 50;
    //PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    ////int count = 0;
    ////for (Boid other : boids) {
    //  float d = PVector.dist(position, target);
    //  if ((d > 0) && (d < neighbordist)) {
    //    sum.add(other.position); // Add position
    //    count++;
    //  }
    //}
    //if (count > 0) {
    //sum.div(count);
    return seek(target);  // Steer towards the position
  }
}