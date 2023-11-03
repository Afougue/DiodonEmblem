

class SpriteSheet {
  PImage spriteSheet;
  int frameWidth;
  int frameHeight;
  int frameDuration;
  float extraX;
  float extraY;
  HashMap<String, List<PImage>> animations;

  SpriteSheet(String imageFileName, String jsonFileName) {
    spriteSheet = loadImage(imageFileName);
    JSONObject json = loadJSONObject(jsonFileName);
    frameWidth = json.getInt("frameWidth");
    frameHeight = json.getInt("frameHeight");
    frameDuration = json.getInt("frameDuration");
    extraX = json.getFloat("extraX");
    extraY = json.getFloat("extraY");
    animations = new HashMap<String, List<PImage>>();

    JSONObject lists = json.getJSONObject("lists");
    for (var animation : lists.keys()) { 
      String animationName = (String) animation;
      List<PImage> frames = extractFrames(lists.getJSONArray(animationName));
      for(PImage image : frames){
        image.resize(image.width*2,image.height*2);  
      }
      
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
