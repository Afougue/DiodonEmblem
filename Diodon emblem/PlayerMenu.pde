import java.util.Arrays;

public class PlayerMenu {

  final int nbLines = 10;
  private int selectedIndex = 0;
  boolean enable = false;

  ArrayList<String> menuItems;

  // Variables to draw on screen
  int x, y, h, w;
  int cursorX1, cursorX2;
  int cursorY1, cursorY2, cursorY3;

  public PlayerMenu(float x, float y, float h, float w) {
    menuItems = new ArrayList<>(Arrays.asList("Figth", "End turn", "Test 1", "Test 2", "Test 3"));

    this.x = (int)x;
    this.y = (int)y;
    this.h = (int)h;
    this.w = (int)w;

    cursorX1 = (int)x - 5;
    cursorX2 = (int)x + 5;

    cursorY1 = (int)y + 10;
    cursorY2 = (int)y + 20;
    cursorY3 = (int)y + 30;
  }

  void drawCursorAtIndex() {
    fill(color(255, 177, 74));
    int offsetY = selectedIndex * h / nbLines;
    
    triangle(cursorX1, cursorY1 + offsetY,
      cursorX2, cursorY2  + offsetY,
      cursorX1, cursorY3  + offsetY); // cursorX3 = cursorX1 so we don't need an extra variable
    fill(color(255, 255, 255));
  }
  
  void changeIndexByOvering() {    
    if (!cursorInsideMenu()) {
        selectedIndex = 0;
        return;
    }
    
    selectedIndex = (int)((mouseY - y) / (float)h * nbLines);
    
    if(selectedIndex >= menuItems.size())
      selectedIndex = 0;
  }
  
 boolean cursorInsideMenu() {
   return !(mouseX - x < 0 || mouseX - x > w || mouseY - y < 0 || mouseY - y > h);
 }

  void draw() {
    // BattleManager frame
    
    fill(enable ? color(255, 255, 255) : color(200, 200, 200));
    rect(x, y, w, h);
    
    if(!enable)
      return;

    // Draw cursor
    drawCursorAtIndex();

    // Draw text underline
    noStroke();
    fill(color(255, 177, 74));
    
    final int maxTextChar = 8;
    int currentTextChar = menuItems.get(selectedIndex).length();
    //String currentText = menuItems.get(selectedIndex);
    //int currentTextChar = currentText.size();
    
    rect(x + 10, y + 35 + h/nbLines * selectedIndex,
      (w - 20) * (float)currentTextChar / maxTextChar, 3);

    stroke(0);
    fill(color(255, 255, 255));

    // Draw texts
    textSize(30);
    fill(color(0, 0, 0));

    int i = 0;
    for (var s : menuItems) {
      text(s, x + 5, y + 30 + h/nbLines * i++);
    }
  }
}
