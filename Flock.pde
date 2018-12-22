// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run(int displayWingsFrame) {
    pushMatrix();
    for (Boid b : boids) {
      b.run(boids, displayWingsFrame);  // Passing the entire list of boids to each boid individually
      //b.seek(new PVector(curves[0][0].curr.x-w*3/4, curves[0][0].curr.y - w*3/4));
      //b.seek(new PVector(curves[0][0].curr.x-w*3/4, curves[0][0].curr.y - w*3/4));

    }
    popMatrix();
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}