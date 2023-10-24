public class BattleManager {

  // Variable to handle fights
  boolean batteling = false;
  Character hero;
  Character villain;

  boolean heroTurn = true;

  // Variables to draw on screen
  int x, y, h, w;

  public BattleManager(float x, float y, float h, float w) {
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;
  }

  void startBattle(Character h, Character v) {
    hero = h;
    villain = v;
    batteling = true;
  }

  void play() {
    if (!batteling)
      return;

    if (!heroTurn)
      hero.hp -= villain.damage();
    else
      villain.hp -= hero.damage();

    if (hero.hp < 0 || villain.hp < 0)
      batteling = false;

    heroTurn = !heroTurn;

    if (heroTurn)
      batteling = false;
  }

  void draw() {
    // BattleManager frame
    rect(x, y, w, h);

    // Terrain quadrilateral
    int x1, x2, x3, x4;
    int y1, y2, y3, y4;

    int b1 = width/2, b2 = height/2; // Base coordinate for the quad

    x1 = b1 - w/4;
    y1 = b2;

    x2 = b1 - w/3;
    y2 = b2 + h/4;

    x3 = b1 + w/4;
    y3 = b2;

    x4 = b1 + w/3;
    y4 = b2 + h/4;

    fill(color(9, 173, 3));
    quad(x1, y1, x3, y3, x4, y4, x2, y2);

    // Draw characters
    if (hero.hp > 0) {
      fill(color(0, 0, 255));
      rect(200, 230, 50, 80);
    }

    if (villain.hp > 0) {
      fill(color(255, 0, 0));
      rect(390, 230, 50, 80);
    }

    // Display characters informations
    fill(color(0, 0, 0));

    //Display names
    textSize(20);
    text(hero.name, x + 10, y + 20);
    text(villain.name, x + w - 80, y + 20);

    // Display HP
    text("HP: " + hero.hp, x + 10, y + h - 30);
    text("HP: " + villain.hp, x + w - 60, y + h - 30);

    // Display Strength;
    text("STR: " + hero.strength, x + 10, y + h - 10);
    text("STR: " + villain.strength, x + w - 60, y + h - 10);

    fill(color(255, 255, 255));
  }
}
