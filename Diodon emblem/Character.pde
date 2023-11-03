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
  float moveSpeed = 4;



  public Character(String name, boolean blue, int hp, int str, int spd, boolean fly) {
    this.name = name;
    hpMax = this.hp = hp;

    isBlue = blue;
    strength = str;
    speed = spd;
    flying = fly;

    hasAttacked = false;
    hasMoved = false;

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
  }

  void draw(PVector position) {
    fill(isBlue ? color(0, 0, 255) : color(255, 0, 0));
    
    if (!moving) {


      hoverY += hoverStep;
      if (hoverY > 10 || hoverY < 0) hoverStep *= -1;
      if (!flying) hoverY = 0;
      rect(position.x - 17, position.y-60 - hoverY, 35, 60);
    } else {
      // go closer to next position
      if (movingX > movingPath.get(0).x) {
        movingX = max(movingPath.get(0).x, movingX-moveSpeed);
      } else {
        movingX = min(movingPath.get(0).x, movingX+moveSpeed);
      }

      if (movingY > movingPath.get(0).y) {
        movingY = max(movingPath.get(0).y, movingY-moveSpeed);
      } else {
        movingY = min(movingPath.get(0).y, movingY+moveSpeed);
      }

      rect(movingX - 17, movingY-60 - hoverY, 35, 60);


      if (movingX == movingPath.get(0).x && movingY == movingPath.get(0).y) {
        movingPath.remove(0);
        if (movingPath.isEmpty()) {
          moving = false;
        }
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
