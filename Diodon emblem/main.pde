import java.util.Optional;
import java.util.ArrayList;

World         world;
BattleManager battleManager;
PlayerMenu    playerMenu;
InventoryMenu inventoryMenu;

ArrayList<Character> characters;

void setup () {
  size(640, 640);

  characters = new ArrayList<>();
  var c = new Character("Manu", true, 20, 5, 3);
  c.newPosition(2, 3);
  var c2 = new Character("Ciao", false, 15, 7, 2);
  c2.newPosition(5, 3);

  ArrayList<Tool> cTools = new ArrayList<>(Arrays.asList(new Weapon("Couteau", 5, 1), new Weapon("Épée", 10, 1)));
  ArrayList<Tool> c2Tools = new ArrayList<>(Arrays.asList(new Weapon("Épingle", 2, 1), new Weapon("Massue", 7, 1)));

  c.tools = cTools;
  c2.tools = c2Tools;

  characters.add(c);
  characters.add(c2);

  battleManager = new BattleManager(width * 0.1, height * 0.1, height * 0.8, width * 0.8);
  world = new World(8, 8, 100, 50, 400, 400, characters);
  playerMenu = new PlayerMenu(world.x + world.w + 10, // Place the playerMenu next to the fieldManager
    world.y,
    world.h,
    width - (world.x + world.w + 20));

  inventoryMenu = new InventoryMenu(world.x,
    world.y + world.h + 10,
    height - (world.y + world.h + 20),
    world.w);
}

void  draw() {
  background(255);

  update();

  if (battleManager.batteling)
    battleManager.draw();
  else {
    world.draw();
    playerMenu.draw();
    inventoryMenu.draw();
  }
}

void update() {
  boolean enableMenus = world.currentState == WorldMenuState.WaitingForPlayerAction;

  playerMenu.enable = enableMenus;
  inventoryMenu.enable = enableMenus;

  inventoryMenu.currentChar = world.selectedCharacter;
}

void mousePressed() {
  world.mousePressed();

  if (battleManager.batteling) {
    battleManager.play();
  }

  if (playerMenu.selectedIndex == 0 && playerMenu.cursorInsideMenu() && !battleManager.batteling) {
    battleManager.startBattle(characters.get(0), characters.get(1));
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

  if (inventoryMenu.enable)
    inventoryMenu.updateCurrentOveringToolIndex();
}
