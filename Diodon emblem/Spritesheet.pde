enum spriteState{
  idle,
  attack,
  run,
  breathing,
  death,
  hit
}

class SpriteSheet {
  PImage spriteSheet;
  int frameWidth;
  int frameHeight;
  int frameDuration;
  float extraX;
  float extraY;
  float width,height;
  spriteState state;
  int currentFrame;
  HashMap<String, List<PImage>> animations;
  float sizeFactor;
  

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
    currentFrame = 0;
    sizeFactor = 1;
    

    JSONObject lists = json.getJSONObject("lists");
    for (var animation : lists.keys()) { 
      String animationName = (String) animation;
      List<PImage> frames = extractFrames(lists.getJSONArray(animationName));
      
      animations.put(animationName, frames);
      println(animationName);
    }
    frameWidth *= 2;
    frameHeight *=2;
  }

  List<PImage> extractFrames(JSONArray framesInfo) {
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
  
  void setSizeFactor(float newSizeFactor){
    sizeFactor = newSizeFactor;
    this.height = frameHeight*sizeFactor;
    this.width = frameWidth*sizeFactor;
  }
  
  PImage getNextFrame(){
    currentFrame = currentFrame + 1;
    if(currentFrame >= animations.get(state.name()).size()){
      currentFrame = 0;
    }
    PImage currentAnimation = animations.get(state.name()).get(currentFrame).copy();
    //currentAnimation.resize(frameWidth*sizeFactor,frameHeight*sizeFactor);
    return currentAnimation;
  }

  int getFrameDuration() {
    return frameDuration;
  }

  float getExtraX() {
    return extraX;
  }

  float getExtraY() {
    return extraY;
  }
}
