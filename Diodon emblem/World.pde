class Exploration {
  MapCell cell;
  int distance;
  boolean explored;

  Exploration(MapCell mapCell, int distance) {
    this.cell = mapCell;
    this.distance = distance;
    explored = false;
  }
}


public enum WorldMenuState {
  Idle, MovingChar, WaitingForPlayerAction, EndTurn, emptyCellSelected, playerSelected
}

class World {
  int rows, cols;
  float tileHeight;
  float tileWidth;
  MapCell[][] tiles;

  ArrayList<Character> characters;
  ArrayList<Character> enemiesInRange;

  Character selectedCharacter = null;
  MapCell selectedCell = null;

  // Display variables
  int x, y, h, w;
  int nbRows = 8, nbCols = 8;

  WorldMenuState currentState = WorldMenuState.Idle;

  World(int rows, int cols, float x, float y, float h, float w) {
    // display position
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;

    // Field informations
    this.rows = rows;
    this.cols = cols;
    this.tiles = new MapCell[rows][cols];
    //this.tileSize =

    // Characters informations
    characters = new ArrayList<Character>();
    enemiesInRange = new ArrayList<Character>();

    // generating map (for now empty grassy terrain)
    tileHeight = h / cols;
    tileWidth = w / rows;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        float rand = random(1);
        if (rand > 0.8) {
          tiles[i][j] = new MapCell(CellType.MOUNTAIN, tileHeight, tileWidth, j, i);
        } else {
          tiles[i][j] = new MapCell(CellType.GRASS, tileHeight, tileWidth, j, i);
        }
      }
    }
  }

  Character findCharAtCoordinates(int tileX, int tileY) {
    Optional<Character> firstMatch = characters.stream()
      .filter(c -> c.fieldPosX == tileX && c.fieldPosY == tileY)
      .findFirst();

    if (!firstMatch.isPresent())
      return null;
    return firstMatch.get();
  }

  boolean isTileInSpeedRangeOfSelectedChar(int tileX, int tileY) {
    if (selectedCharacter == null)
      return false;

    int dx = Math.abs(tileX - selectedCharacter.fieldPosX);
    int dy = Math.abs(tileY - selectedCharacter.fieldPosY);
    return dx + dy <= selectedCharacter.speed && tileX >= 0 && tileX < nbRows && tileY >= 0 && tileY < nbCols;
  }

  ArrayList<MapCell> getNeighborCells(int x, int y) {
    ArrayList<MapCell> neighborCells = new ArrayList<MapCell>();

    if (x > 0) {// left
      neighborCells.add(tiles[y][x-1]);
    }
    if (x < cols-1) {
      neighborCells.add(tiles[y][x+1]);
    }
    if (y > 0) {
      neighborCells.add(tiles[y-1][x]);
    }
    if (y < rows-1) {
      neighborCells.add(tiles[y+1][x]);
    }
    return neighborCells;
  }

  void highlightAccessibleTiles() {
    ArrayList<Exploration> ExplorableCells = new ArrayList<Exploration>();

    // Add initial cell
    ExplorableCells.add(new Exploration(tiles[selectedCharacter.fieldPosY][selectedCharacter.fieldPosX], selectedCharacter.speed));
    while (!ExplorableCells.isEmpty()) {
      MapCell exploringCell = ExplorableCells.get(0).cell;
      int exploringDistance = ExplorableCells.get(0).distance;

      // remove curren cell and don't
      if (exploringDistance <= 0 || exploringCell.type == CellType.MOUNTAIN) {
        exploringCell.highlighted = true;
        ExplorableCells.remove(0);
      } else {
        ArrayList<MapCell> neighborCells = getNeighborCells(exploringCell.idX, exploringCell.idY);

        for (MapCell cell : neighborCells) {
          if (!cell.highlighted && (cell.type != CellType.MOUNTAIN || selectedCharacter.flying )) {
            ExplorableCells.add(new Exploration(cell, exploringDistance-1));
          }
        }
        exploringCell.highlighted = true;
        ExplorableCells.remove(0);
      }
    }
  }

  void unHighlightAccessibleTiles() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        tiles[i][j].highlighted = false;
      }
    }
  }

  void moveSelectedCharacter(int tileX, int tileY) {
    println("Moving ", selectedCharacter.name, " from (", selectedCharacter.fieldPosX, ',', selectedCharacter.fieldPosX, ") to (", tileX, ',', tileY, ")");
    if (selectedCharacter == null)
      return;

    // Check if there's alreay a character on this tile
    if (findCharAtCoordinates(tileX, tileY) != null)
      return;

    selectedCharacter.newPosition(tileX, tileY);
  }

  void endTurn() {
    currentState = WorldMenuState.Idle;
    println("Going to state : Idle");
  }

  void mousePressed() {
    if (mouseX - x < 0 || mouseX - x > w || mouseY - y < 0 || mouseY - y > h) {
      if (mouseX - x < w) {
        currentState = WorldMenuState.Idle;
        unHighlightAccessibleTiles();
        println("Going to state : Idle");
      }
      return;
    }

    int cellX = (int)((mouseX - x) / (float)w * nbRows);
    int cellY = (int)((mouseY - y) / (float)h * nbCols);
    selectedCell = tiles[cellY][cellX];

    switch(currentState) {
    case Idle:
      selectedCharacter = findCharAtCoordinates(cellX, cellY);

      if (selectedCharacter == null)
        break;

      if (!selectedCharacter.isHero)
        break;

      currentState = WorldMenuState.playerSelected;
      highlightAccessibleTiles();
      println("Going to state : playerSelected");

      break;

    case playerSelected:
      if (selectedCell.highlighted) { // If cell is accessible by character
        moveSelectedCharacter(cellX, cellY);
        currentState = WorldMenuState.WaitingForPlayerAction;
        println("Going to state : WaitingForPlayerAction");
      } else {
        println("Cell too far");
        currentState = WorldMenuState.Idle;
        println("Going to state : Idle");
      }

      unHighlightAccessibleTiles();
      break;

    case WaitingForPlayerAction:  // Wait for playerTurnDown() to be called by the main
      //currentState = WorldMenuState.Idle;
      //println("Going to state : Idle");
      break;

    default:
      println("default");
    }
  }

  void draw() {
    boolean ret = false;
    playerMenu.enable = currentState == WorldMenuState.WaitingForPlayerAction;
    if (ret)
      return;
    float tileX = x;
    float tileY = y;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        tiles[i][j].draw(tileX, tileY);
        tileX += tileWidth;
      }
      tileY += tileHeight;
      tileX = x;
    }

    for (var c : characters) {
      c.draw(x, y, w, h, cols, rows);
    }

    switch(currentState) {
    case Idle:
      break;

    case playerSelected:
      //moveCharacter(cellX, cellY);
      //fillEnemiesInRange(); // Check if there're enemies next to the new position
      //moveToNextState();
      break;

    case WaitingForPlayerAction:
      break;

    default:
      println("default");
    }
  }
}
