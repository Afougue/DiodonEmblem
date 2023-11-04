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
  Idle, PlayerSelected, EnemySelected, MovingChar, WaitingForPlayerAction, EndTurn, emptyCellSelected
}

class World {
  float tileHeight;
  float tileWidth;
  MapCell[][] tiles;

  ArrayList<Character> characters;

  ArrayList<MapCell> accessibleTiles;
  ArrayList<MapCell> attackableTiles;
  ArrayList<Character> charactersInRange;
  Random random = new Random();

  Character selectedCharacter = null;
  MapCell selectedCell = null;

  // Display variables
  float x, y, h, w;
  int nbRows, nbCols;
  boolean enable = true;
  PImage fightCursor = loadImage("data/cursor/mouseCursor.png");


  WorldMenuState currentState = WorldMenuState.Idle;

  World(int rows, int cols, float x, float y, float h, float w, ArrayList<Character> chars) {
    // display position
    this.x = x;
    this.y = y;
    this.h = h;
    this.w = w;

    // Field informations
    this.nbRows = rows;
    this.nbCols = cols;
    this.tiles = new MapCell[rows][cols];

    // Characters informations
    characters = chars;
    charactersInRange = new ArrayList<>();
    accessibleTiles = new ArrayList<>();
    attackableTiles = new ArrayList<>();

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
    tiles[3][2].type = CellType.GRASS;
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
    if (x < nbCols-1) {
      neighborCells.add(tiles[y][x+1]);
    }
    if (y > 0) {
      neighborCells.add(tiles[y-1][x]);
    }
    if (y < nbRows-1) {
      neighborCells.add(tiles[y+1][x]);
    }
    return neighborCells;
  }

  void highlightAccessibleTiles() {
    ArrayList<Exploration> ExplorableCells = new ArrayList<Exploration>();
    accessibleTiles = new ArrayList<>();

    // Add initial cell
    ExplorableCells.add(new Exploration(tiles[selectedCharacter.fieldPosY][selectedCharacter.fieldPosX], selectedCharacter.speed));
    while (!ExplorableCells.isEmpty()) {
      MapCell exploringCell = ExplorableCells.get(0).cell;
      int exploringDistance = ExplorableCells.get(0).distance;

      // remove curren cell and don't
      if (exploringDistance <= 0 || (exploringCell.type == CellType.MOUNTAIN && !selectedCharacter.flying)) {
        if (!accessibleTiles.contains(exploringCell)) {
          accessibleTiles.add(exploringCell);
          exploringCell.highlighted = true;
        }
      } else {
        ArrayList<MapCell> neighborCells = getNeighborCells(exploringCell.idX, exploringCell.idY);

        for (MapCell cell : neighborCells) {
          if (!cell.highlighted && (cell.type != CellType.MOUNTAIN || selectedCharacter.flying )) {
            if (selectedCharacter.flying || findCharAtCoordinates(cell.idX, cell.idY) == null) { // can go over enemy character if flying
              cell.previous = exploringCell;
              ExplorableCells.add(new Exploration(cell, exploringDistance-1));
            }
          }
        }
        if (!accessibleTiles.contains(exploringCell)) {
          accessibleTiles.add(exploringCell);
          exploringCell.highlighted = true;
        }
      }
      ExplorableCells.remove(0);
    }
  }

  void highlightAttackableTiles() {
    unHighlightAttackableTiles();
    ArrayList<Exploration> ExplorableCells = new ArrayList<Exploration>();
    attackableTiles = new ArrayList<>();
    charactersInRange = new ArrayList<>();

    // Add initial cell in the explorationList
    ExplorableCells.add(new Exploration(tiles[selectedCharacter.fieldPosY][selectedCharacter.fieldPosX], selectedCharacter.getCurrentToolRange()));

    // Explore cells one by one
    while (!ExplorableCells.isEmpty()) {
      // Get current cell and distance left with characters if any
      MapCell exploringCell = ExplorableCells.get(0).cell;
      int exploringDistance = ExplorableCells.get(0).distance;
      Character exploringChar = findCharAtCoordinates(exploringCell.idX, exploringCell.idY);

      // If distance is 0 validate the current cell
      if (exploringDistance <= 0) {
        exploringCell.attackRange = true;
        if (!attackableTiles.contains(exploringCell)) {
          attackableTiles.add(exploringCell);
        }
        if (exploringChar != null && ! charactersInRange.contains(exploringChar)) {
          charactersInRange.add(exploringChar);
        }
      } else {
        // Add neighbor cell to be explored
        ArrayList<MapCell> neighborCells = getNeighborCells(exploringCell.idX, exploringCell.idY);
        for (MapCell cell : neighborCells) {
          if (!cell.attackRange) {
            ExplorableCells.add(new Exploration(cell, exploringDistance-1));
          }
        }

        //Validate the current cell
        exploringCell.attackRange = true;
        if (!attackableTiles.contains(exploringCell)) {
          attackableTiles.add(exploringCell);
        }
        if (exploringChar != null && !charactersInRange.contains(exploringChar)) {
          charactersInRange.add(exploringChar);
        }
      }
      ExplorableCells.remove(0);
    }
    // Can a character target itself ?
    charactersInRange.remove(selectedCharacter);
    tiles[selectedCharacter.fieldPosY][selectedCharacter.fieldPosX].attackRange = false;

    println("Targetable characters :");
    for (Character c : charactersInRange) {
      println(c.name);
    }
    println();
  }

  void unHighlightAccessibleTiles() {
    for (MapCell cell : accessibleTiles) {
      cell.highlighted = false;
      cell.previous = null;
    }
    accessibleTiles.clear();
  }

  void unHighlightAttackableTiles() {
    for (MapCell cell : attackableTiles) {
      cell.attackRange = false;
    }
    attackableTiles.clear();
    charactersInRange.clear();
  }

  void moveSelectedCharacter(MapCell tile) {
    println("Moving ", selectedCharacter.name, " from (", selectedCharacter.fieldPosX, ',', selectedCharacter.fieldPosY, ") to (", tile.idX, ',', tile.idY, ")");
    selectedCharacter.addMovingPath(tile.getPath());
    selectedCharacter.newPosition(tile.idX, tile.idY);
    unHighlightAccessibleTiles();
    unHighlightAttackableTiles();
    selectedCharacter.hasMoved = true;
  }

  void endTurn() {
    unHighlightAccessibleTiles();
    unHighlightAttackableTiles();
    moveCiaoRandomSpace();
    for (var c : characters) {
      c.hasMoved = false;
      c.hasAttacked =false;
    }
    currentState = WorldMenuState.Idle;
    println("Going to state : Idle");
    selectedCharacter = null;
  }

  void mousePressed() {
    if (mouseX - x < 0 || mouseX - x > w || mouseY - y < 0 || mouseY - y > h) {
      if (mouseX - x < w && mouseY - y < h ) {
        currentState = WorldMenuState.Idle;
        unHighlightAccessibleTiles();
        unHighlightAttackableTiles();
        println("Going to state : Idle");
      }
      return;
    }

    int cellX = (int)((mouseX - x) / (float)w * nbRows);
    int cellY = (int)((mouseY - y) / (float)h * nbCols);
    Character targetedChar = findCharAtCoordinates(cellX, cellY);
    selectedCell = tiles[cellY][cellX];

    switch(currentState) {
    case Idle:
      if (targetedChar == null)
        break;
      selectedCharacter = targetedChar;

      if (selectedCharacter.isBlue) {
        // For a playable char
        if (!selectedCharacter.hasMoved)
          highlightAccessibleTiles();
        if (!selectedCharacter.hasAttacked)
          highlightAttackableTiles();
        currentState = WorldMenuState.PlayerSelected;
        println("Going to state : playerSelected");
        break;
      } else {
        // For an enemy char
        highlightAccessibleTiles();
        currentState = WorldMenuState.EnemySelected;
        println("Going to state : playerSelected");
        break;
      }

    case EnemySelected:
      if (targetedChar == null) {
        currentState = WorldMenuState.Idle;
        println("Going to state : Idle");
        unHighlightAccessibleTiles();
        selectedCharacter = null;
        break;
      }

      if (targetedChar.isBlue) {
        unHighlightAccessibleTiles();

        selectedCharacter = targetedChar;
        if (!selectedCharacter.hasMoved)
          highlightAccessibleTiles();
        if (!selectedCharacter.hasAttacked)
          highlightAttackableTiles();
        currentState = WorldMenuState.PlayerSelected;
        println("Going to state : Idle");
        break;
      } else {
        unHighlightAccessibleTiles();
        selectedCharacter = targetedChar;
        highlightAccessibleTiles();
        break;
      }

    case PlayerSelected:

      // If targeting another character
      if (targetedChar != null) {
        // If allied character switch view to him
        if (targetedChar.isBlue) {
          unHighlightAttackableTiles();
          unHighlightAccessibleTiles();
          selectedCharacter = targetedChar;
          if (!selectedCharacter.hasMoved)
            highlightAccessibleTiles();
          if (!selectedCharacter.hasAttacked)
            highlightAttackableTiles();
          break;
        } else {
          // If not allied

          // If in range and can attack
          if (charactersInRange.contains(targetedChar) && !selectedCharacter.hasAttacked) {
            println("Starting battle between", selectedCharacter.name, "and", targetedChar.name);
            battleManager.startBattle(selectedCharacter, targetedChar);
            unHighlightAttackableTiles();
            unHighlightAccessibleTiles();
            selectedCharacter.hasMoved = true;
            selectedCharacter.hasAttacked = true;
            selectedCharacter = null;
            currentState = WorldMenuState.Idle;
            println("Going to state : Idle");
            break;
          } else {
            // Else switch view to enemy
            unHighlightAttackableTiles();
            unHighlightAccessibleTiles();
            selectedCharacter = targetedChar;
            highlightAccessibleTiles();
            currentState = WorldMenuState.EnemySelected;
            println("Going to state : playerSelected");
            break;
          }
        }
      }else if (selectedCell.highlighted && !selectedCharacter.hasMoved) { // Move if possible
        moveSelectedCharacter(selectedCell);
        println("Going to state : MovingChar");
        currentState = WorldMenuState.MovingChar;
        break;
      }

      // Finally return to idle if nothing should have had happenned
      unHighlightAttackableTiles();
      unHighlightAccessibleTiles();
      selectedCharacter = null;
      currentState = WorldMenuState.Idle;
      println("Going to state : Idle");

    case MovingChar:
      // If targeting a character
      if (targetedChar != null) {

        // If allied character switch view to him
        if (targetedChar.isBlue && targetedChar != selectedCharacter) {
          selectedCharacter = targetedChar;
          if (!selectedCharacter.hasMoved)
            highlightAccessibleTiles();
          if (!selectedCharacter.hasAttacked)
            highlightAttackableTiles();
          break;
        } else {
          // Else switch view to enemy
          unHighlightAttackableTiles();
          unHighlightAccessibleTiles();
          selectedCharacter = targetedChar;
          highlightAccessibleTiles();
          currentState = WorldMenuState.EnemySelected;
          println("Going to state : playerSelected");
          break;
        }
      }
      // Else go to Idle state
      currentState = WorldMenuState.Idle;
      println("Going to state : Idle");
      unHighlightAccessibleTiles();
      selectedCharacter = null;

      break;




    default:
      println("default");
    }
  }

  void moveCiaoRandomSpace() {
    selectedCharacter = null;
    for (Character c : characters ) {
      if (c.name == "Ciao") {
        selectedCharacter = c;
      }
    }
    if (selectedCharacter != null) {
      highlightAccessibleTiles();
      int randomIndex = random.nextInt(accessibleTiles.size());
      MapCell randomAccessibleCell = accessibleTiles.get(randomIndex);
      moveSelectedCharacter(randomAccessibleCell);
    }
  }

  void updateCharacterRange(Character c) {
    if (c == selectedCharacter) {
      unHighlightAttackableTiles();
      highlightAttackableTiles();
    }
  }

  void draw() {

    // TODO DO that an other way as tiles shouldn't really be updating theyr position ?
    float tileX = x;
    float tileY = y;
    for (int i = 0; i < nbRows; i++) {
      for (int j = 0; j < nbCols; j++) {
        tiles[i][j].draw(tileX, tileY);
        tileX += tileWidth;
      }
      tileY += tileHeight;
      tileX = x;
    }

    int mouseTileX = (int)(((mouseX - x) / (float)w) * nbRows);
    int mouseTileY = (int)(((mouseY - y) / (float)h) * nbCols);

    Character targetedChar = findCharAtCoordinates(mouseTileX, mouseTileY);

    textSize(20);
    fill(0);
    switch(currentState) {
    case Idle:
      text("Idle", 10, 30);
      break;

    case PlayerSelected:
      text("PlayerSelected", 10, 30);

      text(selectedCharacter.name, 10, 60);

      MapCell hoverCell = null;
      if (mouseTileX >=0 && mouseTileX < nbCols && mouseTileY >= 0 && mouseTileY < nbRows)
        hoverCell = tiles[mouseTileY][mouseTileX];

      if (hoverCell != null && hoverCell.previous != null) {
        hoverCell.displayPoint();
      }
      break;

    case EnemySelected:
      text("EnemySelected", 10, 30);
      break;

    case WaitingForPlayerAction:
      text("WaitingForPlayerAction", 10, 30);
      break;

    case MovingChar:
      text("MovingChar", 10, 30);
      // Change state if character has finished moving
      if (selectedCharacter != null && !selectedCharacter.moving ) {
        currentState = WorldMenuState.PlayerSelected;
        highlightAttackableTiles();
      }
      break;

    default:
      println("default");
    }

    // Sort the list of character to display the furthest one first
    Comparator<Character> ascendingComparator = (c1, c2) -> c1.fieldPosY - c2.fieldPosY;
    Collections.sort(characters, ascendingComparator);

    for (var c : characters) {
      c.draw(tiles[c.fieldPosY][c.fieldPosX].getCharacterPos());
      //c.draw(x, y, w, h, nbCols, nbRows);
    }

    if (targetedChar != null && charactersInRange.contains(targetedChar) && !targetedChar.isBlue) {
      noCursor();
      image(fightCursor, mouseX - fightCursor.width/2, mouseY - fightCursor.height/2);
    } else {
      cursor();
    }
  }
}
