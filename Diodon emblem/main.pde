import java.util.Optional;

World  world;
BattleManager battleManager;
PlayerMenu    playerMenu;

ArrayList<Character> characters;

void setup () {
  size(640, 480);

  characters = new ArrayList<>();
  var c = new Character("Manu", true, 20, 5, 3);
  c.newPosition(2, 3);
  var c2 = new Character("Ciao", false, 15, 7, 2);
  c2.newPosition(5, 3);
  
  characters.add(c);
  characters.add(c2);

  battleManager = new BattleManager(width * 0.1, height * 0.1, height * 0.8, width * 0.8);
  world = new World(8, 8, 100, 50, 400, 400);
  playerMenu = new PlayerMenu(world.x + world.w + 10, // Place the playerMenu next to the fieldManager
    world.y,
    world.h,
    width - (world.x + world.w + 20));
    
    world.characters = characters;
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
    battleManager.startBattle(characters.get(0), characters.get(1));
    //world.resetSelectedChar();
    //world.playerTurnDone();
  }

  if (playerMenu.selectedIndex == 1 && !battleManager.batteling && world.currentState == WorldMenuState.WaitingForPlayerAction) {
    world.endTurn();
    playerMenu.selectedIndex = 0;
  }

  println("");
}

void mouseMoved() {
  if (playerMenu.enable)
    playerMenu.changeIndexByOvering();
}
