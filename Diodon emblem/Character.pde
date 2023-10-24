public class Character {
  String name;
  int hpMax, hp, strength, speed;
  boolean isHero;
  boolean flying = false;

  // Display variables
  int fieldPosX, fieldPosY;

  public Character(String name, boolean hero, int hp, int str, int spd) {
    this.name = name;
    hpMax = this.hp = hp;

    isHero = hero;
    strength = str;
    speed = spd;

    fieldPosX = 5;
    fieldPosY = 3;
  }

  void newPosition(int cellX, int cellY) {
    fieldPosX = cellX;
    fieldPosY = cellY;
  }

  void draw(float x, float y, float w, float h, float cols, float rows) {
    fill(isHero ? color(0, 0, 255) : color(255, 0, 0));
    rect(x + w/rows * fieldPosX + 7, y + h/cols * fieldPosY - 20, 35, 60);
  }
}
