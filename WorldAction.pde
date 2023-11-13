class WorldAction {

  World w;

  WorldAction(World world) {
    w = world;
  }

  void idle(Character targetedChar) {
    if (targetedChar == null)
      return;
    w.selectedCharacter = targetedChar;

    if (w.selectedCharacter.isBlue) {
      // For a playable char
      if (!w.selectedCharacter.hasMoved)
        w.highlightAccessibleTiles();
      if (!w.selectedCharacter.hasAttacked)
        w.highlightAttackableTiles();
      w.currentState = WorldMenuState.PlayerSelected;
      println("Going to state : playerSelected");
      return;
    } else {
      // For an enemy char
      w.highlightAccessibleTiles();
      w.currentState = WorldMenuState.EnemySelected;
      println("Going to state : playerSelected");
      return;
    }
  }

  void enemySelected(Character targetedChar) {
    if (targetedChar == null) {
      w.currentState = WorldMenuState.Idle;
      println("Going to state : Idle");
      w.unHighlightAccessibleTiles();
      w.selectedCharacter = null;
      return;
    }

    if (targetedChar.isBlue) {
      w.unHighlightAccessibleTiles();

      w.selectedCharacter = targetedChar;
      if (!w.selectedCharacter.hasMoved)
        w.highlightAccessibleTiles();
      if (!w.selectedCharacter.hasAttacked)
        w.highlightAttackableTiles();
      w.currentState = WorldMenuState.PlayerSelected;
      println("Going to state : Idle");
      return;
    } else {
      w.unHighlightAccessibleTiles();
      w.selectedCharacter = targetedChar;
      w.highlightAccessibleTiles();
      return;
    }
  }

  void playerSelected(Character targetedChar) {

    // If targeting another character
    if (targetedChar != null) {
      // If allied character switch view to him
      if (targetedChar.isBlue) {
        w.unHighlightAttackableTiles();
        w.unHighlightAccessibleTiles();
        w.selectedCharacter = targetedChar;
        if (!w.selectedCharacter.hasMoved)
          w.highlightAccessibleTiles();
        if (!w.selectedCharacter.hasAttacked)
          w.highlightAttackableTiles();
        return;
      } else {
        // If not allied

        // If in range and can attack
        if (w.charactersInRange.contains(targetedChar) && !w.selectedCharacter.hasAttacked) {
          println("Starting battle between", w.selectedCharacter.name, "and", targetedChar.name);
          battleManager.initBattle(w.selectedCharacter, targetedChar);
          w.unHighlightAttackableTiles();
          w.unHighlightAccessibleTiles();
          w.selectedCharacter.hasMoved = true;
          w.selectedCharacter.hasAttacked = true;
          w.selectedCharacter = null;
          w.currentState = WorldMenuState.Idle;
          println("Going to state : Idle");
          return;
        } else {
          // Else switch view to enemy
          w.unHighlightAttackableTiles();
          w.unHighlightAccessibleTiles();
          w.selectedCharacter = targetedChar;
          w.highlightAccessibleTiles();
          w.currentState = WorldMenuState.EnemySelected;
          println("Going to state : playerSelected");
          return;
        }
      }
    } else if (w.selectedCell.highlighted && !w.selectedCharacter.hasMoved) { // Move if possible
      w.moveSelectedCharacter(w.selectedCell);
      println("Going to state : MovingChar");
      w.currentState = WorldMenuState.MovingChar;
      return;
    }

    // Finally return to idle if nothing should have had happenned
    w.unHighlightAttackableTiles();
    w.unHighlightAccessibleTiles();
    w.selectedCharacter = null;
    w.currentState = WorldMenuState.Idle;
    println("Going to state : Idle");
  }


  void movingChar(Character targetedChar) {

    // If targeting a character
    if (targetedChar != null) {

      // If allied character switch view to him
      if (targetedChar.isBlue && targetedChar != w.selectedCharacter) {
        w.selectedCharacter = targetedChar;
        if (!w.selectedCharacter.hasMoved)
          w.highlightAccessibleTiles();
        if (!w.selectedCharacter.hasAttacked)
          w.highlightAttackableTiles();
        return;
      } else {
        // Else switch view to enemy
        w.unHighlightAttackableTiles();
        w.unHighlightAccessibleTiles();
        w.selectedCharacter = targetedChar;
        w.highlightAccessibleTiles();
        w.currentState = WorldMenuState.EnemySelected;
        println("Going to state : playerSelected");
        return;
      }
    }
    // Else go to Idle state
    w.currentState = WorldMenuState.Idle;
    println("Going to state : Idle");
    w.unHighlightAccessibleTiles();
    w.selectedCharacter = null;
    return;
  }
}
