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
  PImage background;
  BattleManagerState state = BattleManagerState.None;

  // Variables to draw on screen
  int waitTimer = 0;
  int x, y, h, w;
  int heroOffX, villainOffX;

  public BattleManager(float x, float y, float h, float w) {
    background = loadImage("data/battle/battleBackground.png");
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
    hero.setNextState(spriteState.idle);
    villain.setNextState(spriteState.idle);

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
        hero.setNextState(spriteState.run,true);
      }
      break;

    case MovingHeroForward:
      updateCharPosition(true, true);

      if (heroOffX > maxOffset) {
        state = BattleManagerState.HeroAttack;
        hero.setNextState(spriteState.attack,true);
        hero.sprite.setLoopingAnimation(spriteState.idle);
      }
      break;

    case HeroAttack:
      if (!hero.sprite.attackingAnimation) {
        villain.setNextState(spriteState.hit);
        updateHealth(true);
        state = BattleManagerState.VillainTakesDamage;
      }
      break;

    case VillainTakesDamage:
    if (!villain.sprite.hitStun) {
        hero.setNextState(spriteState.walkBack,true);
        // see if necessary
        villain.setNextState(spriteState.idle);

        state = BattleManagerState.MovingHeroBackward;
      }
      break;

    case MovingHeroBackward:
      updateCharPosition(true, false);

      if (heroOffX <= 0) {
        heroOffX = 0;
        state = BattleManagerState.Waiting;
        hero.setNextState(spriteState.idle,true);
      }
      break;

    case Waiting:
      if (waitTimer++ >= waitTimerMax) {
        waitTimer = 0;
        state = BattleManagerState.MovingVillainForward;
        villain.setNextState(spriteState.run,true);
      }
      break;

    case MovingVillainForward:
      updateCharPosition(false, true);

      if (villainOffX > maxOffset) {
        state = BattleManagerState.VillainAttack;
        villain.setNextState(spriteState.attack,true);
        villain.setNextState(spriteState.idle);
      }
      break;

    case VillainAttack:
      if (!villain.sprite.attackingAnimation) {
        hero.setNextState(spriteState.hit);

        updateHealth(false);
        state = BattleManagerState.HeroTakesDamage;
      }
      break;

    case HeroTakesDamage:
    if (!hero.sprite.hitStun) {
        waitTimer = 0;
        villain.setNextState(spriteState.walkBack,true);
        hero.setNextState(spriteState.idle);

        state = BattleManagerState.MovingVillainBackward;
      }
      break;

    case MovingVillainBackward:
      updateCharPosition(false, false);

      if (villainOffX <= 0) {
        villainOffX = 0;
        villain.setNextState(spriteState.idle,true);
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
    image(background,0,0);
    final int floorYCoord = 450; // Use to position characters

    fill(255, 255, 255);

    // BattleManager frame
    fill(0,0);
    rect(x, y, w, h);

     // Draw characters
    if (state == BattleManagerState.Starting || state == BattleManagerState.TransitionFromWorld || state == BattleManagerState.MovingHeroForward || state == BattleManagerState.HeroAttack || state == BattleManagerState.VillainTakesDamage || state == BattleManagerState.MovingHeroBackward){
      // Draw characters
      if (villain.hp > 0) {
        pushMatrix();
        scale(-1, 1); // This flips the image horizontally
        image(villain.sprite.getNextFrame(), -550 + villainOffX, floorYCoord - villain.sprite.height, villain.sprite.width, villain.sprite.height);
        popMatrix();
      }

      if (hero.hp > 0)
        image(hero.sprite.getNextFrame(), 80 + heroOffX, floorYCoord - hero.sprite.height, hero.sprite.width, hero.sprite.height);

    }else{
      if (hero.hp > 0)
        image(hero.sprite.getNextFrame(), 80 + heroOffX, floorYCoord - hero.sprite.height, hero.sprite.width, hero.sprite.height);
  
      if (villain.hp > 0) {
        pushMatrix();
        scale(-1, 1); // This flips the image horizontally
        image(villain.sprite.getNextFrame(), -550 + villainOffX, floorYCoord - villain.sprite.height, villain.sprite.width, villain.sprite.height);
        popMatrix();
      }
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
