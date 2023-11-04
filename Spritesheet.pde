enum spriteState {
  idle,
    attack,
    run,
    breathing,
    death,
    hit
}

class SpriteSheet {
  PImage spriteSheet;
  spriteState state;
  HashMap<String, List<PImage>> animations;

  int frameWidth, frameHeight;
  int currentFrame, frameDuration, lastFrameTime;

  float extraX, extraY;
  float width, height;
  float sizeFactor;
  
  boolean attackingAnimation = false;

  SpriteSheet(String imageFileName, String jsonFileName) {
    spriteSheet = loadImage(imageFileName);
    JSONObject json = loadJSONObject(jsonFileName);
    frameWidth = json.getInt("frameWidth");
    frameHeight = json.getInt("frameHeight");
    this.height = frameHeight;
    this.width = frameWidth;
    frameDuration = json.getInt("frameDuration");
    extraX = json.getFloat("extraX");
    extraY = json.getFloat("extraY");
    animations = new HashMap<String, List<PImage>>();
    state = spriteState.idle;
    sizeFactor = 1;
    lastFrameTime = millis();
    currentFrame = 0;

    JSONObject lists = json.getJSONObject("lists");
    for (var animation : lists.keys()) {
      String animationName = (String) animation;
      List<PImage> frames = extractFrames(lists.getJSONArray(animationName));

      animations.put(animationName, frames);
    }
    frameWidth *= 2;
    frameHeight *=2;
  }

  private List<PImage> extractFrames(JSONArray framesInfo) {
    List<PImage> frames = new ArrayList<PImage>();
    for (int i = 0; i < framesInfo.size(); i++) {
      JSONObject frame = framesInfo.getJSONObject(i);
      int x = frame.getInt("x");
      int y = frame.getInt("y");
      PImage subImage = spriteSheet.get(x, y, frameWidth, frameHeight);
      frames.add(subImage);
    }
    return frames;
  }

  List<PImage> getAnimation(String animation) {
    return animations.get(animation);
  }

  void setSizeFactor(float newSizeFactor) {
    sizeFactor = newSizeFactor;
    this.height = frameHeight*sizeFactor;
    this.width = frameWidth*sizeFactor;
  }
  
  void changeState(spriteState state) {
    this.state = state; 
    currentFrame = 0;
  }

  PImage getNextFrame() {
    var stateAnimations = animations.get(state.name());

    if (millis() - lastFrameTime > frameDuration) {   
       if(currentFrame == 0 && state == spriteState.attack)
         attackingAnimation = true;
      
      if(++currentFrame == stateAnimations.size()) {
        currentFrame = 0;
        
        if(state == spriteState.attack)
           attackingAnimation = false;
      }
      
      lastFrameTime = millis();
    }

    return stateAnimations.get(currentFrame);
  }
}
