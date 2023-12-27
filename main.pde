import java.util.*;
import java.nio.file.*;

World         world;
BattleManager battleManager;
PlayerMenu    playerMenu;
InventoryMenu inventoryMenu;

ArrayList<Character> characters;
PImage icon;

float transitionPercent = 0;

enum PlayerMenuAction {
  None,
    Fight,
    EndTurn
}

void setup () {
  size(640, 640);
  noSmooth();
  icon = loadImage("data/cursor/mouseCursor.png");
  surface.setIcon(icon);

  // Display loading screen cause the setup is sometime laggy
  image(loadImage("data/resources/loadingScreen.jpg"),
    0, 0, width, height);

  characters = new ArrayList<>();
  var c = new Character("Manu", true, 20, 5, 16, false);
  var cBob = new Character("Bob", true, 20, 2, 2, true);
  c.newPosition(2, 3);
  cBob.newPosition(2, 4);
  var c2 = new Character("Ciao", false, 15, 7, 3, true);
  var c3 = new Character("Lennon", false, 10, 4, 1, false);
  c2.newPosition(5, 3);
  c3.newPosition(5, 4);

  ArrayList<Tool> cBobTools = new ArrayList<>(Arrays.asList(new Weapon("Plume", 0, 1), new Weapon("Arc", 1, 4)));
  ArrayList<Tool> cTools = new ArrayList<>(Arrays.asList(new Weapon("Couteau", 5, 1), new Weapon("Épée", 10, 2)));
  ArrayList<Tool> c2Tools = new ArrayList<>(Arrays.asList(new Weapon("Épingle", 2, 1), new Weapon("Massue", 7, 2)));
  ArrayList<Tool> c3Tools = new ArrayList<>(Arrays.asList(new Weapon("La Hache du Pyrobarbare", 2, 1), new Weapon("Massue", 7, 2)));

  c.tools = cTools;
  c2.tools = c2Tools;
  cBob.tools = cBobTools;
  c3.tools = c3Tools;

  characters.add(c);
  characters.add(cBob);
  characters.add(c2);
  characters.add(c3);

  battleManager = new BattleManager(width * 0.1, height * 0.1, height * 0.8, width * 0.8);
  int rows = 8;
  int cols = 8;
  world = new World(rows, cols, 100, 50, 400, 400, characters);

  c.switchTool(0); // needs to be called after world creation for now
  cBob.switchTool(0);
  playerMenu = new PlayerMenu(world.x - 50 + world.w - 40, // Place the playerMenu on the top left corner
    world.y - 20,
    world.h / 3,
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

  if (battleManager.state == BattleManagerState.TransitionFromWorld)
    transitionBattleWorld(true);
  else if (battleManager.state == BattleManagerState.TransitionToWorld)
    transitionBattleWorld(false);
}

void update() {
  boolean enableMenus = (world.currentState == WorldMenuState.WaitingForPlayerAction) || (world.currentState == WorldMenuState.PlayerSelected);

  playerMenu.enable = enableMenus;
  playerMenu.allowFight = world.charactersInRange.size() > 0;
  inventoryMenu.enable = enableMenus;

  inventoryMenu.currentChar = world.selectedCharacter;

  if (battleManager.batteling)
    battleManager.update();
}


void keyPressed() {
  //print(key);
  world.endTurn();
  if (key == 'q' || key == 'Q') {
  }
  if (key == 's' || key == 'S') {
  }
  if (key == 'a' || key == 'A') {
  }
  if (key == 'z' || key == 'Z') {
  }
  if (key == 'e' || key == 'E') {
  }
  if (key == 'r' || key == 'R') {
  }
  if (key == 't' || key == 'T') {
  }
  if (key == 'y' || key == 'Y') {
  }
}

void mousePressed() {
  world.mousePressed();
  if (inventoryMenu.enable)
    inventoryMenu.mousePressed();

  if (playerMenu.enable)
    playerMenu.mousePressed();

  if (battleManager.batteling)
    return;

  if (!playerMenu.enable)
    return;

  switch(playerMenu.getPlayerMenuAction()) {
  case None:
    break;

  case Fight:
    battleManager.initBattle(characters.get(0), characters.get(1));
    break;

  case EndTurn:
    world.endTurn();
    break;

  default:
    break;
  }

  println("");
}

void mouseMoved() {
  if (playerMenu.enable)
    playerMenu.changeIndexByOvering();

  if (inventoryMenu.enable)
    inventoryMenu.updateCurrentOveringToolIndex();
}


String getRandomUnit() {
  try {
    List<String> allLines = Files.readAllLines(Paths.get(sketchPath() + "/data/resources/units.txt"));
    return allLines.get(int(random(1)*allLines.size()));
  }
  catch (IOException e) {
    e.printStackTrace();
  }
  return "f2_general_skindogehai";
}

void transitionBattleWorld(boolean toBattle) {
  fill(0, 0, 0);
  rect(0, 0, width, height * transitionPercent);
  rect(0, height - height * transitionPercent, width, height);
  transitionPercent += 0.02;

  if (transitionPercent >= 0.5) {
    transitionPercent = 0;
    
    if (toBattle)
      battleManager.startBattle();
    else
      battleManager.endBattle();
  }
}
