public class Character {
  String name;
  int hpMax, hp, strength, speed;
  boolean isBlue = false;
  boolean flying = false;

  ArrayList<Tool> tools;
  int selectedToolIndex = -1;

  // Map actions variable
  boolean hasAttacked;
  boolean hasMoved;

  // Display variables
  int fieldPosX, fieldPosY; // col and row
  int isSelected; // might be used later to have a custom animation when char is selected
  float hoverY;
  float hoverStep = 0.4;
  boolean moving =false;
  ArrayList<PVector> movingPath;
  float movingX, movingY;
  float moveSpeed = 2;

  // Spritesheet
  SpriteSheet sprite;
  boolean facingRight;
  int YOffset = 20;



  public Character(String name, boolean blue, int hp, int str, int spd, boolean fly) {
    this.name = name;
    hpMax = this.hp = hp;

    isBlue = blue;
    strength = str;
    speed = spd;
    flying = fly;

    hasAttacked = false;
    hasMoved = false;

    switch (name) {
    case "Bob":
      sprite = new SpriteSheet("f2_buildcommon");
      break;
    case "Manu":
      sprite = new SpriteSheet("f1_sister");
      break;
    case "Ciao":
      sprite = new SpriteSheet("neutral_buildepic");
      break;
    case "Lennon":
      sprite = new SpriteSheet("f2_twilightfox");
      break;
    default:
      sprite = new SpriteSheet("f1_sister");
      break;
    }
    facingRight = blue;

    fieldPosX = 0;
    fieldPosY = 0;
  }

  void switchTool(int idTool) {
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

  void addMovingPath(ArrayList<PVector> path) {
    moving = true;
    movingPath = path;
    movingX = path.get(0).x;
    movingY = path.get(0).y;
    sprite.changeState(spriteState.run);
  }
  
  void changeState(spriteState newSprite){
    sprite.changeState(newSprite);
  }

  void draw(PVector position) {
    fill(isBlue ? color(0, 0, 255) : color(255, 0, 0));

    if (!moving) {
      hoverY += hoverStep;
      if (hoverY > 10 || hoverY < 0) hoverStep *= -1;
      if (!flying) hoverY = 0;
      if (facingRight) {
        image(sprite.getNextFrame(), position.x - sprite.width/2,  position.y - sprite.height + YOffset, sprite.width, sprite.height);
      }else{
        pushMatrix();
        scale(-1, 1); // This flips the image horizontally
        image(sprite.getNextFrame(), - (position.x + sprite.width/2),  position.y - sprite.height + YOffset, sprite.width, sprite.height);
        popMatrix();
      }

    } else {
      if(movingX == movingPath.get(0).x){
        
      }else if (movingX > movingPath.get(0).x) {
        facingRight = false;
        movingX = max(movingPath.get(0).x, movingX-moveSpeed);
      } else {
        facingRight = true;
        movingX = min(movingPath.get(0).x, movingX+moveSpeed);
      }

      if (movingY > movingPath.get(0).y) {
        movingY = max(movingPath.get(0).y, movingY-moveSpeed);
      } else {
        movingY = min(movingPath.get(0).y, movingY+moveSpeed);
      }


      if (movingX == movingPath.get(0).x && movingY == movingPath.get(0).y) {
        movingPath.remove(0);
        if (movingPath.isEmpty()) {
          moving = false;
          sprite.changeState(spriteState.idle);
        }
      }
      
      if (facingRight) {
        image(sprite.getNextFrame(), movingX - sprite.width/2,  movingY - sprite.height + YOffset, sprite.width, sprite.height);
      }else{
        pushMatrix();
        scale(-1, 1); // This flips the image horizontally
        image(sprite.getNextFrame(), - movingX + sprite.width/2, movingY - sprite.height + YOffset, -sprite.width, sprite.height);
        popMatrix();
      }
    }
  }

  int getCurrentToolRange() {
    if (selectedToolIndex == -1) {
      return 0;
    }
    return tools.get(selectedToolIndex).range;
  }
}
