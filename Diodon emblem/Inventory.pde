class InventoryMenu {

  Character currentChar;
  int currentToolIndex = -1;
  int currentOveringToolIndex = -1;

  // Variables to draw on screen
  int x, y, h, w;
  boolean enable = false;
  final int maxToolNb = 3;
  int offsetX = 0;

  InventoryMenu(float x, float y, float h, float w) {
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;

    offsetX = (int)w / maxToolNb;
  }

  void updateCurrentOveringToolIndex() {
    if (!cursorInsideMenu()) {
      currentOveringToolIndex = -1;
      return;
    }

    currentOveringToolIndex = (int)((mouseX - x) / (float)w * maxToolNb);
  }

  boolean cursorInsideMenu() {
    return !(mouseX - x < 0 || mouseX - x > w || mouseY - y < 0 || mouseY - y > h);
  }

  void draw() {
    fill(enable ? color(255, 255, 255) : color(200, 200, 200));
    rect(x, y, w, h);

    if (currentChar == null || !enable)
      return;

    noStroke();
    drawCurrentOveringItemIndexBackground();
    //drawCurrentItemIndexBackground();
    stroke(0);
    drawCurrentCharInv();
  }

  void drawCurrentCharInv() {
    if (currentChar.tools.size() > 3)
      return;

    int i = 0;
    fill(color(0, 0, 0));

    for (var t : currentChar.tools) {
      textSize(30);
      text(t.name, x + 5 + offsetX * i, y + 30);

      textSize(20);
      text("effi: " + t.efficiency, x + 5 + offsetX * i, y + 60);
      text("range: " + t.range, x + 5 + offsetX * i, y + 90);

      i++;
    }
  }

  void drawCurrentItemIndexBackground() {
    if (currentToolIndex >= currentChar.tools.size())
      return;

    fill(130, 200, 255, 128);
    rect(x + 5 + offsetX * currentToolIndex, y + 30, offsetX, h - 10);
  }

  void drawCurrentOveringItemIndexBackground() {
    if (currentOveringToolIndex == -1 || currentOveringToolIndex >= currentChar.tools.size())
      return;

    fill(190, 230, 255, 128);
    rect(x + 3 + offsetX * currentOveringToolIndex, y + 3, offsetX - 3, h - 6);
  }
  
  void mousePressed(){
    
    
  }
}
