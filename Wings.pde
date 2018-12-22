class Wings {
  PImage[] images;
  int frame;
  int r;

  Wings(int count) {
    imageCount = count;
    //images = new PImage[imageCount];
    r = int(random(20));
  }

  void display(float xpos, float ypos, int displayWingsFrame, float speed) {
      frame = (displayWingsFrame+1)*(5/int(speed+1))*3 % imageCount;
      image(wingImages[frame], xpos, ypos);
    
  }

  int getWidth() {
    return images[0].width;
  }
}