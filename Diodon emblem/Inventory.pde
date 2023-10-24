class InventoryMenu {

  ArrayList<Character> characters;

  // Variables to draw on screen
  int x, y, h, w;
  boolean enable = false;
  Character currentChar;

  InventoryMenu(float x, float y, float h, float w, ArrayList<Character> chars) {
    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;

    characters = chars;
  }

  void draw() {
    fill(enable ? color(255, 255, 255) : color(200, 200, 200));
    rect(x, y, w, h);

    if (currentChar != null && enable)
      drawCurrentCharInv();
  }

  void drawCurrentCharInv() {
    if (currentChar.tools.size() > 3)
      return;

    int offsetX = w/3;
    int i = 0;    
    fill(color(0, 0, 0));

    for (var t : currentChar.tools) {
      textSize(30);
      text(t.name, x + 5 + offsetX * i, y + 30);
      
      textSize(20);
      text("effi: " + t.efficiency,  x + 5 + offsetX * i, y + 60);
      text("range: " + t.range, x + 5 + offsetX * i, y + 90);
      
      i++;
    }
  }
}
