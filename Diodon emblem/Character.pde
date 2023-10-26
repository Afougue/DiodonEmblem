public class Character {
  String name;
  int hpMax, hp, strength, speed;
  boolean isHero = false;
  boolean flying = false;

  ArrayList<Tool> tools;
  int selectedToolIndex = -1;

  // Display variables
  int fieldPosX, fieldPosY;
  int isSelected; // might be used later to have a custom animation when char is selected
  float hoverY;
  float hoverStep = 0.1;
  

  public Character(String name, boolean hero, int hp, int str, int spd, boolean fly) {
    this.name = name;
    hpMax = this.hp = hp;

    isHero = hero;
    strength = str;
    speed = spd;
    flying = fly;

    fieldPosX = 0;
    fieldPosY = 0;
  }
  
  void switchTool(int idTool){
    selectedToolIndex = idTool;
    world.updateCharacterRange(this);
  }

  int damage() {
    return strength;
  }

  void newPosition(int cellX, int cellY) {
    fieldPosX = cellX;
    fieldPosY = cellY;
  }

  void draw(float x, float y, float w, float h, float cols, float rows) {
    fill(isHero ? color(0, 0, 255) : color(255, 0, 0));
    
    hoverY += hoverStep;
    if (hoverY > 10 || hoverY < 0) hoverStep *= -1;
    if(!flying) hoverY = 0;
    
    rect(x + w/rows * fieldPosX + 7, y + h/cols * fieldPosY - 20 - hoverY, 35, 60);
  }
  
  int getCurrentToolRange(){
    if (selectedToolIndex == -1){
      return 0;
    }
    return tools.get(selectedToolIndex).range;
  }
  
  
}
