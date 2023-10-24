public class Character {
  String name;
  int hpMax, hp, strength, speed;
  boolean isHero;

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
}
