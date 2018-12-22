// A simple Particle class

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float maxLifespan;
  int rad;

  Particle(PVector l) {
    acceleration = new PVector(random(-.05, .05), random(-.05, .05));
    velocity = new PVector(random(-.01, .01), random(-.01, .01));
    position = l.copy();
    lifespan = 255.0*2;
    maxLifespan = lifespan;
    rad = int(random(1, 5));
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
    acceleration.mult(0);
    
    if(position.y > height+rad || position.y < -rad || position.x > width+rad || position.x < -rad){
      lifespan = -1;
    }
  }

  // Method to display
  void display() {
    int alpha = int(map(lifespan, 0, maxLifespan, 0, 255));
    noStroke();
    fill(255, alpha);
    ellipse(position.x, position.y, rad, rad);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}