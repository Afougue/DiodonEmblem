enum spriteState {
  idle, // looping animation
    attack,
    run, // looping animation
    walkBack, // looping animation
    breathing,
    death,
    hit
}

class SpriteSheet {
  PImage spriteSheet;
  spriteState state;
  String name;
  HashMap<String, List<PImage>> animations;

  int frameWidth, frameHeight;
  int currentFrame, lastFrameTime;
  float frameDuration;

  float extraX, extraY;
  float width, height;
  float sizeFactor;

  // Variable to know if we're in an animation
  boolean attackingAnimation = false;
  boolean hitStun = false;
  spriteState lastLoopingAnimation;
  boolean loopingAnimation; // to loop animation when running or idling
  ArrayList<spriteState> stateQueue;

  SpriteSheet(String unitName) {
    name = unitName;
    String pngPath = "data/resources/troopAnimations4/" + unitName + ".png";
    spriteSheet = loadImage(pngPath);
    String jsonPath = pngPath.replace(".png", ".plist.json");
    JSONObject json = loadJSONObject(jsonPath);

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
    createWalkBackAnimation();
    frameWidth *= 2;
    frameHeight *=2;

    lastLoopingAnimation = spriteState.idle;
    stateQueue = new ArrayList<>();
    stateQueue.add(spriteState.idle);
  }

  private void createWalkBackAnimation() {
    ArrayList<PImage> walkingAnimation = new ArrayList<>(animations.get("run"));
    Collections.reverse(walkingAnimation);
    animations.put("walkBack", walkingAnimation);
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
  
  void setLoopingAnimation(spriteState state){
    lastLoopingAnimation = state;
  }

  void setSizeFactor(float newSizeFactor) {
    sizeFactor = newSizeFactor;
    this.height = frameHeight*sizeFactor;
    this.width = frameWidth*sizeFactor;
  }
  
  void setNextState(spriteState state) {
    setNextState(state,false);
  }

  void setNextState(spriteState state, boolean skip) {
    if (!stateQueue.contains(state)) {
      stateQueue.add(state);

      if (state == spriteState.idle || state == spriteState.run || state == spriteState.walkBack) {
        setLoopingAnimation(state);
      }
      if(skip){
        skipCurrentFrame();
      }

      if (state == spriteState.attack)
        attackingAnimation = true;
      else if (state == spriteState.hit)
        hitStun = true;

      println("Added: ", state.name(), " animation to: ", name);
    }
  }

  void skipCurrentFrame() {
    currentFrame = animations.get(state.name()).size()-1;
    if (state == spriteState.attack)
      attackingAnimation = false;
    else if (state == spriteState.hit)
      hitStun = false;
  }

  PImage getNextFrame() {

    // check if next frame time has come
    if (millis() - lastFrameTime > frameDuration) {
      currentFrame++;
      int animationSize = animations.get(state.name()).size();

      // If end of current animation, go to the next one
      if (currentFrame >= animationSize) {
        currentFrame = 0; // reset current frame number
        /////////////////// Faire des fonctions pour ce qu'il y a ensuite ? ///////////////////
        if (state == spriteState.attack)
          attackingAnimation = false;
        else if (state == spriteState.hit)
          hitStun = false;
        /////////////////////////////////////
        //var lastAnimation = stateQueue.get(0);
        stateQueue.remove(0); // delete last animation from queue

        // If there is no more animations add the last looping one
        if (stateQueue.isEmpty()) {
          stateQueue.add(lastLoopingAnimation);
        }

        state = stateQueue.get(0);
      }
      lastFrameTime = millis();
    }
    if (animations.get(state.name()).size() == 0)
      println("Animation ", state.name(), " of ", name, " is of size 0");
    return animations.get(state.name()).get(currentFrame);
  }
}
