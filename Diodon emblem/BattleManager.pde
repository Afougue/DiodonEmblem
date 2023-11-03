enum BattleManagerState {
  None,
    MovingHeroForward,
    HeroAttack,
    MovingHeroBackward,
    Waiting,
    MovingVillainForward,
    VillainAttack,
    MovingVillainBackward
}

public class BattleManager {
  // Variable to handle fights
  boolean batteling = false;
  Character hero;
  Character villain;
  BattleManagerState state = BattleManagerState.None;

  // Variables to draw on screen
  int waitTimer = 0;
  int x, y, h, w;
  int heroOffX, villainOffX;

  // Sprites
  SpriteSheet heroSprite, villainSprite;

  public BattleManager(float x, float y, float h, float w) {
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;

    heroSprite =    new SpriteSheet("data/resources/troopAnimations/f1_sister.png", "data/resources/troopAnimations/f1_sister.plist.json");
    villainSprite = new SpriteSheet("data/resources/troopAnimations/f2_katara.png", "data/resources/troopAnimations/f2_katara.plist.json");

    heroSprite.setSizeFactor(1.5);
    villainSprite.setSizeFactor(1.5);
  }

  void startBattle(Character h, Character v) {
    hero = h;
    villain = v;
    batteling = true;
    heroOffX = villainOffX = 0;
  }

  void update() {
    final int maxOffset = 50;
    final int waitTimerMax = 50;

    switch(state) {
    case None:
      if (waitTimer++ >= waitTimerMax) {
        waitTimer = 0;
        state = BattleManagerState.MovingHeroForward;
        heroSprite.state = spriteState.run;
      }
      break;

    case MovingHeroForward:
      updateCharPosition(true, true);

      if (heroOffX > maxOffset) {
        state = BattleManagerState.HeroAttack;
      }
      break;

    case HeroAttack:
      updateHealth(true);
      state = BattleManagerState.MovingHeroBackward;
      break;

    case MovingHeroBackward:
      updateCharPosition(true, false);

      if (heroOffX <= 0) {
        heroOffX = 0;
        state = BattleManagerState.Waiting;
        heroSprite.state = spriteState.idle;
      }
      break;

    case Waiting:
      if (waitTimer++ >= waitTimerMax) {
        waitTimer = 0;
        state = BattleManagerState.MovingVillainForward;
        villainSprite.state = spriteState.run;
      }
      break;

    case MovingVillainForward:
      updateCharPosition(false, true);

      if (villainOffX > maxOffset) {
        state = BattleManagerState.VillainAttack;
      }
      break;

    case VillainAttack:
      updateHealth(false);
      state = BattleManagerState.MovingVillainBackward;
      break;

    case MovingVillainBackward:
      updateCharPosition(false, false);

      if (villainOffX <= 0) {
        villainOffX = 0;
        state = BattleManagerState.None;
        villainSprite.state = spriteState.idle;
        batteling = false;
      }
      break;
    }

    // Check if a character died
    if (hero.hp <= 0 || villain.hp <= 0) {
      batteling = false;
      characters.remove(hero.hp <= 0 ? hero : villain);
    }
  }

  // Change characters positions to animate the fight
  private void updateCharPosition(boolean moveHero, boolean moveForward) {
    if (moveHero) {
      heroOffX += moveForward ? 1 : -1;
    } else {
      villainOffX += moveForward ? 1 : -1;
    }
  }

  // Remove Hp
  private void updateHealth(boolean heroAttacking) {
    if (!heroAttacking)
      hero.hp -= villain.damage();
    else
      villain.hp -= hero.damage();
  }

  void draw() {
    final int floorYCoord = 450; // Use to position characters

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
    if (hero.hp > 0)
      image(heroSprite.getNextFrame(), 80 + heroOffX, floorYCoord - heroSprite.height, heroSprite.width, heroSprite.height);

    if (villain.hp > 0) {
      pushMatrix();
      scale(-1, 1); // This flips the image horizontally
      image(villainSprite.getNextFrame(), -550 + villainOffX, floorYCoord - villainSprite.height, villainSprite.width, villainSprite.height);
      popMatrix();
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
