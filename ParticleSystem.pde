// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  int numParticles = 20;
  float spread = 5;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle(PVector offset) {
    for (int i = 0; i < numParticles; i++) {
      PVector randomSpread = new PVector(random(-spread, spread), random(-spread, spread));
      particles.add(new Particle(offset.add(randomSpread)));
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}