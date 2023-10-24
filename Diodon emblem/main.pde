FieldManager  fieldManager;
BattleManager battleManager;
PlayerMenu    playerMenu;

void setup () {
  size(640, 480);
  battleManager = new BattleManager(width * 0.1, height * 0.1, height * 0.8, width * 0.8);
  fieldManager = new FieldManager(100, 50, 400, 400);
  playerMenu = new PlayerMenu(fieldManager.x + fieldManager.w + 10, // Place the playerMenu next to the fieldManager
    fieldManager.y,
    fieldManager.h,
    width - (fieldManager.x + fieldManager.w + 20));
}

void  draw() {
  background(255);

  if (battleManager.batteling)
    battleManager.draw();
  else {
    fieldManager.draw();
    playerMenu.draw();

    playerMenu.enable = fieldManager.characterMovementDone;
  }
}

void keyPressed() {
}

void mousePressed() {
  //println("mouseClick : ",mouseX," ",mouseY);
  fieldManager.onClick();

  if (battleManager.batteling) {
    battleManager.play();
  }

  if (playerMenu.selectedIndex == 0 && playerMenu.cursorInsideMenu() && !battleManager.batteling) {
    //battleManager.startBattle(new Character("Patrick", true, 50, 10, 2), new Character("Titouan", false, 30, 8, 2));
    fieldManager.resetSelectedChar();
    fieldManager.playerTurnDone();
  }
}

void mouseMoved() {
  if (playerMenu.enable)
    playerMenu.changeIndexByOvering();
}
