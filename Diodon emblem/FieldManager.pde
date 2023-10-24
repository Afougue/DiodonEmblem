import java.util.Optional;

public enum FieldManagerState {
  Idle, MovingChar, WaitingForPlayerAction, EndTurn, emptyCellSelected, playerSelected
}

public class FieldManager {
  int[][] cells = new int[8][8];

  ArrayList<Character> characters;
  ArrayList<Character> enemiesInRange;

  Character selectedCharacter = null;
  boolean characterMovementDone = false;
  private boolean isPlayerTurnDone = false;

  FieldManagerState currentState = FieldManagerState.Idle;

  // Display variables
  int x, y, h, w;
  int nbRows = 8, nbCols = 8;
  int clickedTileX = -1, clickedTileY = -1;
  
  World world;

  public FieldManager(float x, float y, float h, float w) {
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;

    characters = new ArrayList<Character>();
    var c = new Character("Manu", true, 20, 5, 3);
    c.fieldPosX = 2;
    characters.add(c);
    characters.add(new Character("Ciao", false, 15, 7, 2));

    enemiesInRange = new ArrayList<Character>();
    world = new World(8, 8, x, y, h, w);
  }

  void moveToNextState() {
    FieldManagerState[] states = FieldManagerState.values();
    int nextOrdinal = (currentState.ordinal() + 1) % states.length;

    currentState = states[nextOrdinal];
  }
  
  void playerTurnDone() {
    isPlayerTurnDone = true;
    currentState = FieldManagerState.Idle;
  }

  void onClick() {
    world.onClick();
    if (mouseX - x < 0 || mouseX - x > w || mouseY - y < 0 || mouseY - y > h)
      return;

    int tmpX = (int)((mouseX - x) / (float)w * nbRows);
    int tmpY = (int)((mouseY - y) / (float)h * nbCols);

    switch(currentState) {
    case Idle:
      //println("Idle");
      selectedCharacter = findCharAtCoordinates(tmpX, tmpY);
      clickedTileX = tmpX;
      clickedTileY = tmpY;
      moveToNextState();

      break;

    case MovingChar:
      //println("MovingChar");
      moveCharacter(tmpX, tmpY);
      fillEnemiesInRange(); // Check if there're enemies next to the new position
      moveToNextState();
      
      break;

    case WaitingForPlayerAction:  // Wait for playerTurnDown() to be called by the main
      //println("WaitingForPlayerAction");
      break;

    default:
      //println("default");
    }
  }

  void moveCharacter(int tileX, int tileY) {
    if (selectedCharacter == null)
      return;

    // Move previously selected character
    if (!isTileInSpeedRangeOfSelectedChar(tileX, tileY)) // Check if new tile is in range for the character
      return;

    // Check if there's alreay a character on this tile
    if (findCharAtCoordinates(tileX, tileX) != null)
      return;

    // No problem with the clicked tile, so we save it's position
    clickedTileX = tileX;
    clickedTileY = tileY;

    selectedCharacter.fieldPosX = clickedTileX;
    selectedCharacter.fieldPosY = clickedTileY;
    characterMovementDone = true;
  }

  void resetSelectedChar() {
    selectedCharacter = null;
    characterMovementDone = false;
  }

  boolean isTileInSpeedRangeOfSelectedChar(int tileX, int tileY) {
    if (selectedCharacter == null)
      return false;

    int dx = Math.abs(tileX - selectedCharacter.fieldPosX);
    int dy = Math.abs(tileY - selectedCharacter.fieldPosY);
    return dx + dy <= selectedCharacter.speed && tileX >= 0 && tileX < nbRows && tileY >= 0 && tileY < nbCols;
  }

  boolean isTileInDamageRangeOfSelectedChar(int tileX, int tileY) {
    if (selectedCharacter == null)
      return false;

    int dx = Math.abs(tileX - selectedCharacter.fieldPosX);
    int dy = Math.abs(tileY - selectedCharacter.fieldPosY);
    return dx + dy == 1 && tileX >= 0 && tileX < nbRows && tileY >= 0 && tileY < nbCols;
  }

  void fillEnemiesInRange() {
    var tmp = characters.stream()
      .filter(c -> isTileInDamageRangeOfSelectedChar(c.fieldPosX, c.fieldPosY))
      .toList();

    enemiesInRange = new ArrayList<>(tmp);
  }

  Character findCharAtCoordinates(int tileX, int tileY) {
    Optional<Character> firstMatch = characters.stream()
      .filter(c -> c.fieldPosX == tileX && c.fieldPosY == tileY)
      .findFirst();

    if (!firstMatch.isPresent())
      return null;
    return firstMatch.get();
  }

  void draw() {
    // Draw grid
    stroke(color(150, 150, 150));
    for (int i = 0; i < nbRows; i++) {
      for (int j = 0; j < nbCols; j++) {

        color tileColor;
        if (clickedTileX == i && clickedTileY == j && selectedCharacter != null && !characterMovementDone)
          tileColor = color(255, 177, 74);
        else if (isTileInSpeedRangeOfSelectedChar(i, j) && !characterMovementDone)
          tileColor = color(255, 233, 92);
        else if (isTileInDamageRangeOfSelectedChar(i, j) && characterMovementDone && enemiesInRange.size() > 0)
          tileColor = color(200, 50, 50);
        else
          tileColor = color(255, 255, 255);

        fill(tileColor);
        rect(x + i * w/nbRows, y + j * h/nbCols, w/nbRows, h/nbCols);
      }
    }
    stroke(color(0, 0, 0));

    // Draw characters
    for (var c : characters) {
      fill(c.isHero ? color(0, 0, 255) : color(255, 0, 0));
      rect(x + w/nbRows * c.fieldPosX + 7, y + h/nbCols * c.fieldPosY - 20, 35, 60);
    }
    
    world.draw();
    fill(color(255, 255, 255));
  }
}
