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
  Idle, PlayerSelected, EnemySelected, MovingChar, WaitingForPlayerAction, EndTurn, emptyCellSelected, 
}

class World {
  int rows, cols;
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
  int x, y, h, w;
  int nbRows = 8, nbCols = 8;
  boolean enable = true;
  PImage fightCursor = loadImage("data/cursor/mouseCursor.png");


  WorldMenuState currentState = WorldMenuState.Idle;

  World(int rows, int cols, float x, float y, float h, float w, ArrayList<Character> chars) {
    // display position
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;

    // Field informations
    this.rows = rows;
    this.cols = cols;
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
        if(!attackableTiles.contains(exploringCell)){
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
        if(!attackableTiles.contains(exploringCell)){
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
    for (MapCell cell :accessibleTiles){
      cell.highlighted = false;
    }
    accessibleTiles.clear();
  }

  void unHighlightAttackableTiles() {
    for (MapCell cell :attackableTiles){
      cell.attackRange = false;
    }
    attackableTiles.clear();
    charactersInRange.clear();
  }

  void moveSelectedCharacter(int tileX, int tileY) {
    println("Moving ", selectedCharacter.name, " from (", selectedCharacter.fieldPosX, ',', selectedCharacter.fieldPosY, ") to (", tileX, ',', tileY, ")");
    selectedCharacter.newPosition(tileX, tileY);
    unHighlightAccessibleTiles();
    unHighlightAttackableTiles();
    highlightAttackableTiles();
    selectedCharacter.hasMoved = true;
  }

  void endTurn() {
    unHighlightAccessibleTiles();
    unHighlightAttackableTiles();
    moveCiaoRandomSpace();
    for (var c : characters){
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
    Character targetedChar = findCharAtCoordinates(cellX,cellY);
    selectedCell = tiles[cellY][cellX];

    switch(currentState) {
      case Idle:
        if (targetedChar == null)
          break;
        selectedCharacter = targetedChar;
          
        if(selectedCharacter.isBlue){
          // For a playable char
          if (!selectedCharacter.hasMoved)
            highlightAccessibleTiles();
          if (!selectedCharacter.hasAttacked)
          highlightAttackableTiles();
          currentState = WorldMenuState.PlayerSelected;
          println("Going to state : playerSelected");
          break;
        }else{
          // For an enemy char
          highlightAccessibleTiles();
          currentState = WorldMenuState.EnemySelected;
          println("Going to state : playerSelected");
          break;
        }
      
      case EnemySelected:
        if (targetedChar == null){
          currentState = WorldMenuState.Idle;
          println("Going to state : Idle");
          unHighlightAccessibleTiles();
          selectedCharacter = null;
          break;
        }
        
        if(targetedChar.isBlue){
          unHighlightAccessibleTiles();
          
          selectedCharacter = targetedChar;
          if(!selectedCharacter.hasMoved)
            highlightAccessibleTiles();
          if(!selectedCharacter.hasAttacked)
            highlightAttackableTiles();
          currentState = WorldMenuState.PlayerSelected;
          println("Going to state : Idle");
          break;
        }else{
          unHighlightAccessibleTiles();
          selectedCharacter = targetedChar;
          highlightAccessibleTiles();
          break;
        }
  
      case PlayerSelected:
        // Move if possible
        if (selectedCell.highlighted && !selectedCharacter.hasMoved && targetedChar == null) { // Vérifier si problème en volant ? 
          moveSelectedCharacter(cellX, cellY);
          break;
        }
        
        // If targeting a character
        if(targetedChar != null){
          
          // If allied character switch view to him
          if(targetedChar.isBlue){
            unHighlightAttackableTiles();
            unHighlightAccessibleTiles();
            selectedCharacter = targetedChar;
            if (!selectedCharacter.hasMoved)
              highlightAccessibleTiles();
            if (!selectedCharacter.hasAttacked)
              highlightAttackableTiles();
            break;
          }else{
            // If not allied
            
            // If in range and can attack
            if (charactersInRange.contains(targetedChar) && !selectedCharacter.hasAttacked){
              println("Starting battle between",selectedCharacter.name,"and",targetedChar.name);
              battleManager.startBattle(selectedCharacter,targetedChar);
              unHighlightAttackableTiles();
              unHighlightAccessibleTiles();
              selectedCharacter.hasMoved = true;
              selectedCharacter.hasAttacked = true;
              selectedCharacter = null;
              currentState = WorldMenuState.Idle;
              println("Going to state : Idle");
              break;
            }else{
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
        }
        
        // Finally return to idle if nothing should have had happenned
        unHighlightAttackableTiles();
        unHighlightAccessibleTiles();
        selectedCharacter = null;
        currentState = WorldMenuState.Idle;
        println("Going to state : Idle");
        
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
      moveSelectedCharacter(randomAccessibleCell.idX,randomAccessibleCell.idY);
      unHighlightAccessibleTiles();
    }
  }
  
  void updateCharacterRange(Character c){
    if (c == selectedCharacter){
      unHighlightAttackableTiles();
      highlightAttackableTiles();
    }
  }

  void draw() {
    
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
    
    int mouseTileX = (int)((mouseX - x) / (float)w * nbRows);
    int mouseTileY = (int)((mouseY - y) / (float)h * nbCols);
    Character targetedChar = findCharAtCoordinates(mouseTileX,mouseTileY);
    if (targetedChar != null && charactersInRange.contains(targetedChar) && !targetedChar.isBlue){
      noCursor();
      image(fightCursor, mouseX - fightCursor.width/2, mouseY - fightCursor.height/2);
    }else{
      cursor();
    }


    textSize(20);
    if (selectedCharacter != null){
      text(selectedCharacter.name,10,60);
    }
    switch(currentState) {
    case Idle:
      text("Idle",10,30);
      break;

    case PlayerSelected:
      text("PlayerSelected",10,30);
      break;

    case EnemySelected:
      text("EnemySelected",10,30);
      break;

    case WaitingForPlayerAction:
      text("WaitingForPlayerAction",10,30);
      break;

    default:
      println("default");
    }
  }
}
