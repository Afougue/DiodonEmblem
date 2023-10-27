import java.util.Optional;
import java.util.ArrayList;
import java.util.Random;

World         world;
BattleManager battleManager;
PlayerMenu    playerMenu;
InventoryMenu inventoryMenu;

ArrayList<Character> characters;
PImage icon;

void setup () {
  size(640, 640);
  icon = loadImage("data/cursor/mouseCursor.png");
  surface.setIcon(icon);

  characters = new ArrayList<>();
  var c = new Character("Manu", true, 20, 5, 3, false);
  c.newPosition(2, 3);
  var c2 = new Character("Ciao", false, 15, 7, 2, true);
  c2.newPosition(5, 3);

  ArrayList<Tool> cTools = new ArrayList<>(Arrays.asList(new Weapon("Couteau", 5, 1), new Weapon("Épée", 10, 2)));
  ArrayList<Tool> c2Tools = new ArrayList<>(Arrays.asList(new Weapon("Épingle", 2, 1), new Weapon("Massue", 7, 2)));

  c.tools = cTools;
  c2.tools = c2Tools;

  characters.add(c);
  characters.add(c2);

  battleManager = new BattleManager(width * 0.1, height * 0.1, height * 0.8, width * 0.8);
  world = new World(8, 8, 100, 50, 400, 400, characters);
  
  c.switchTool(0); // needs to be called after world creation for now 
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
  boolean enableMenus = (world.currentState == WorldMenuState.WaitingForPlayerAction) || (world.currentState == WorldMenuState.playerSelected);

  playerMenu.enable = enableMenus || (world.currentState == WorldMenuState.Idle);
  inventoryMenu.enable = enableMenus;

  inventoryMenu.currentChar = world.selectedCharacter;
}

void mousePressed() {
  if (battleManager.batteling) {
    battleManager.play();
    return;
  }

  world.mousePressed();
  if (inventoryMenu.enable)
    inventoryMenu.mousePressed();

  if (playerMenu.enable)
    playerMenu.mousePressed();

  if (playerMenu.selectedIndex == 0 && playerMenu.cursorInsideMenu() && !battleManager.batteling) {
    battleManager.startBattle(characters.get(0), characters.get(1));
  }

  if (playerMenu.selectedIndex == 1 && !battleManager.batteling) {
    world.endTurn();
  }

  println("");
}

void mouseMoved() {
  if (playerMenu.enable)
    playerMenu.changeIndexByOvering();

  if (inventoryMenu.enable)
    inventoryMenu.updateCurrentOveringToolIndex();
}
