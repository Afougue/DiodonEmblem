int k_up = 0;
int k_down = 1;
int k_left = 2;
int k_right = 3;
int k_a = 4;
int k_z = 5;
int k_e = 6;

void loadAllUnitNames() {
  File folder = new File(sketchPath("data/resources/troopAnimations/"));
  File[] files = folder.listFiles();
  if (files != null) {
    for (File file : files) {
      if (file.isFile() && file.getName().endsWith(".png")) {
        String unitName = file.getName().replace(".png", "");

        unitsNames.add(unitName);
      }
    }
  }
}


SpriteSheet loadSpriteSheet(String spriteName) {

  String imagePath = "data/resources/troopAnimations/"+spriteName+".png";
  String jsonPath = imagePath.replace(".png", ".plist.json");

  SpriteSheet spriteSheet = new SpriteSheet(imagePath, jsonPath);
  return spriteSheet;
}
