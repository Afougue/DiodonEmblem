import java.io.File; //<>//
boolean[] keys = new boolean[128];
ArrayList<String> unitsNames = new ArrayList<String>();
int currentSpriteIndex = 0;
Unit player;
/*
void setup() {
  noSmooth();
  size(400, 400);
  unitsNames = new ArrayList<>();
  loadAllUnitNames();
  int randomIndex = (int) random(unitsNames.size());
  player = new Unit(loadSpriteSheet(unitsNames.get(randomIndex)), "idle");
}

void draw() {
  background(200);

  player.update();


  player.draw();
}



void mousePressed() {
  if (mouseButton == LEFT) {
    player.mousePressed();
  } else {
    int randomIndex = (int) random(unitsNames.size());
    player.changeSpriteSheet(loadSpriteSheet(unitsNames.get(randomIndex)));
  }
}

void keyPressed() {
  print(key);
  if (key == 'q' || key == 'Q') {
    // Change to a random sprite sheet
    
  }
  if (key == 's' || key == 'S') {
    // Change to a random sprite sheet
    
  }
  if (key == 'a' || key == 'A') {
    // Change to a random sprite sheet
    player.changeAnimation("hit");
  }
  if (key == 'z' || key == 'Z') {
    // Change to a random sprite sheet
    player.changeAnimation("death");
  }
  if (key == 'e' || key == 'E') {
    // Change to a random sprite sheet
    player.changeAnimation("breathing");
  }
  if (key == 'r' || key == 'R') {
    // Change to a random sprite sheet
    player.changeAnimation("idle");
  }
  if (key == 't' || key == 'T') {
    // Change to a random sprite sheet
    player.changeAnimation("attack");
  }
  if (key == 'y' || key == 'Y') {
    // Change to a random sprite sheet
    player.changeAnimation("run");
  }

  boolean value = true;
  if (key == 'r' || key == 'R') {
  };
  if (key == CODED) {
    if (keyCode == UP) {
      keys[0] = value;
    } else if (keyCode == DOWN) {
      keys[1] = value;
    } else if (keyCode == LEFT) {
      keys[2] = value;
    } else if (keyCode == RIGHT) {
      keys[3] = value;
    }
  }
}


void keyReleased() {
  boolean value = false;
  if (key == CODED) {
    if (keyCode == UP) {
      keys[k_up] = value;
    } else if (keyCode == DOWN) {
      keys[k_down] = value;
    } else if (keyCode == LEFT) {
      keys[k_left] = value;
    } else if (keyCode == RIGHT) {
      keys[k_right] = value;
    }
  }
}*/
