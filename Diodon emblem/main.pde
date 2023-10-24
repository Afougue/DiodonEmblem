import java.util.Optional;

World  world;
BattleManager battleManager;
PlayerMenu    playerMenu;

void setup () {
  size(640, 480);
  battleManager = new BattleManager(width * 0.1, height * 0.1, height * 0.8, width * 0.8);
  world = new World(8,8,100, 50, 400, 400);
  playerMenu = new PlayerMenu(world.x + world.w + 10, // Place the playerMenu next to the fieldManager
    world.y,
    world.h,
    width - (world.x + world.w + 20));
}

void  draw() {
  background(255);
  
  //update();

  if (battleManager.batteling)
    battleManager.draw();
  else {
    world.draw();
    playerMenu.draw();
  }
}

void mousePressed() {
  world.mousePressed();

  if (battleManager.batteling) {
    battleManager.play();
  }
  
  if (playerMenu.selectedIndex == 0 && playerMenu.cursorInsideMenu() && !battleManager.batteling) {
    battleManager.startBattle(new Character("Patrick", true, 50, 10, 2), new Character("Titouan", false, 30, 8, 2));
    world.resetSelectedChar();
    world.playerTurnDone();
  }
}

void mouseMoved() {
  if (playerMenu.enable)
    playerMenu.changeIndexByOvering();
}
