class Unit {
  SpriteSheet spriteSheet;
  String currentState;
  int currentFrame;
  int lastFrameTime;
  float x, y;
  float speed = 4;
  boolean flipped = false;
  boolean attacking = false;

  Unit(SpriteSheet spriteSheet, String initialState) {
    this.spriteSheet = spriteSheet;
    currentState = initialState;
    currentFrame = 0;
    lastFrameTime = millis();
    x=width/2;
    y=height/2;
  }

  void changeAnimation(String newState) {
    if (!currentState.equals(newState)) {
      currentState = newState;
      currentFrame = 0;
      lastFrameTime = millis();
    }
  }

  void changeSpriteSheet(SpriteSheet newSpriteSheet) {
    spriteSheet = newSpriteSheet;
    currentFrame = 0;
  }

  void update() {
    boolean mooving = false;
    if (attacking) {
      
      
    } else {
      if (keys[k_right]) {
        x+= speed;
        flipped = false;
        mooving = true;
      }
      if (keys[k_left]) {
        x-= speed;
        flipped = true;
        mooving = true;
      }
      if (keys[k_up]) {
        y-= speed;
        mooving = true;
      }
      if (keys[k_down]) {
        y+= speed;
        mooving = true;
      }
      if (mooving) {
        this.changeAnimation("run");
      } else {
        this.changeAnimation("idle");
      }
    }
  }

  void mousePressed() {
    if (! attacking) {
      this.attacking = true;
      currentFrame = 0;
      this.changeAnimation("attack");
    }
  }

  void draw() {
    List<PImage> animation = spriteSheet.getAnimation(currentState);
    int frameDuration = spriteSheet.frameDuration;

    if (millis() - lastFrameTime > frameDuration) {
      currentFrame = currentFrame + 1;
      if (currentFrame == animation.size()){
        currentFrame = 0;
        if(attacking){
          changeAnimation("idle");
          attacking = false;
        }
      }
      lastFrameTime = millis();
    }

    PImage frame = animation.get(currentFrame);
    if (flipped) {
      pushMatrix();
      scale(-1, 1); // This flips the image horizontally
      image(frame, -(x + spriteSheet.frameHeight / 2), y - spriteSheet.frameWidth);
      popMatrix();
    } else {
      image(frame, x - spriteSheet.frameHeight/2, y - spriteSheet.frameWidth);
    }
  }
}
