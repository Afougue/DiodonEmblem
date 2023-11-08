enum BattleManagerState {
  None,
    TransitionFromWorld,
    Starting,
    MovingHeroForward,
    HeroAttack,
    VillainTakesDamage,
    MovingHeroBackward,
    Waiting,
    MovingVillainForward,
    VillainAttack,
    HeroTakesDamage,
    MovingVillainBackward,
    BattleEnded,
    TransitionToWorld
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

  public BattleManager(float x, float y, float h, float w) {
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;
  }

  void initBattle(Character h, Character v) {
    hero = h;
    villain = v;

    heroOffX = villainOffX = 0;
    state = BattleManagerState.TransitionFromWorld;
  }

  void startBattle() {
    hero.sprite.setSizeFactor(1.5);
    villain.sprite.setSizeFactor(1.5);

    state = BattleManagerState.Starting;
    batteling = true;
  }

  void endBattle() {
    hero.changeState(spriteState.idle);
    villain.changeState(spriteState.idle);

    hero.sprite.setSizeFactor(0.5);
    villain.sprite.setSizeFactor(0.5);

    state = BattleManagerState.None;
    batteling = false;
  }

  void update() {
    final int maxOffset = 50;
    final int waitTimerMax = 50;

    switch(state) {
    case None:
    case TransitionFromWorld:
      break;

    case Starting:
      if (waitTimer++ >= waitTimerMax) {
        waitTimer = 0;
        state = BattleManagerState.MovingHeroForward;
        hero.sprite.changeState(spriteState.run);
      }
      break;

    case MovingHeroForward:
      updateCharPosition(true, true);

      if (heroOffX > maxOffset) {
        state = BattleManagerState.HeroAttack;
        hero.sprite.changeState(spriteState.attack);
      }
      break;

    case HeroAttack:
      if (!hero.sprite.attackingAnimation) {
        villain.sprite.changeState(spriteState.hit);

        updateHealth(true);
        state = BattleManagerState.VillainTakesDamage;
      }
      break;

    case VillainTakesDamage:
    if (!villain.sprite.hitStun) {
        hero.sprite.changeState(spriteState.walkBack);
        villain.sprite.changeState(spriteState.idle);

        state = BattleManagerState.MovingHeroBackward;
      }
      break;

    case MovingHeroBackward:
      updateCharPosition(true, false);

      if (heroOffX <= 0) {
        heroOffX = 0;
        state = BattleManagerState.Waiting;
        hero.sprite.changeState(spriteState.idle);
      }
      break;

    case Waiting:
      if (waitTimer++ >= waitTimerMax) {
        waitTimer = 0;
        state = BattleManagerState.MovingVillainForward;
        villain.sprite.changeState(spriteState.run);
      }
      break;

    case MovingVillainForward:
      updateCharPosition(false, true);

      if (villainOffX > maxOffset) {
        state = BattleManagerState.VillainAttack;
        villain.sprite.changeState(spriteState.attack);
      }
      break;

    case VillainAttack:
      if (!villain.sprite.attackingAnimation) {
        hero.sprite.changeState(spriteState.hit);

        updateHealth(false);
        state = BattleManagerState.HeroTakesDamage;
      }
      break;

    case HeroTakesDamage:
    if (!hero.sprite.hitStun) {
        waitTimer = 0;
        villain.sprite.changeState(spriteState.walkBack);
        hero.sprite.changeState(spriteState.idle);

        state = BattleManagerState.MovingVillainBackward;
      }
      break;

    case MovingVillainBackward:
      updateCharPosition(false, false);

      if (villainOffX <= 0) {
        villainOffX = 0;
        villain.sprite.changeState(spriteState.idle);
        state = BattleManagerState.BattleEnded;
      }
      break;

    case BattleEnded:
      if (waitTimer++ >= waitTimerMax) {
        waitTimer = 0;
        state = BattleManagerState.TransitionToWorld;
      }

    case TransitionToWorld:
      break;
    }

    // Check if a character died
    if (hero.hp <= 0 || villain.hp <= 0) {
      endBattle();
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

    fill(255, 255, 255);

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
      image(hero.sprite.getNextFrame(), 80 + heroOffX, floorYCoord - hero.sprite.height, hero.sprite.width, hero.sprite.height);

    if (villain.hp > 0) {
      pushMatrix();
      scale(-1, 1); // This flips the image horizontally
      image(villain.sprite.getNextFrame(), -550 + villainOffX, floorYCoord - villain.sprite.height, villain.sprite.width, villain.sprite.height);
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
