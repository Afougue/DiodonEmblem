
public enum CellType {
  GRASS, WATER, MOUNTAIN, FOREST
}

class MapCell {
  CellType type;
  //float tileSize = 10;
  float tileHeight;
  float tileWidth;
  boolean highlighted = false;
  boolean attackRange = false;
  int idX;
  int idY;
  float lastX = 0;
  float lastY = 0;
  MapCell previous = null;

  MapCell(CellType tileType, float w, float h, int ix, int iy) {
    type = tileType;
    //tileSize = size;
    tileHeight = h;
    tileWidth = w;
    highlighted = false;
    idX = ix;
    idY = iy;
  }
  
  void displayPoint(){
    fill(255,200);
    ellipse(lastX + tileWidth/2, lastY + tileHeight/2, 10, 10);
    if (previous != null){
      float midX = (lastX + tileWidth/2 + previous.lastX + tileWidth/2)/2;
      float midY = (lastY + tileHeight/2 + previous.lastY + tileHeight/2)/2;
      ellipse(midX, midY, 10, 10);
      previous.displayPoint();
    }
  }

  void draw(float x, float y) {
    lastX = x;
    lastY = y;
    color c = color(0, 0, 0);
    switch(type) {
    case GRASS:
      c = color(59, 218, 96);
      break;
    case WATER:
      c = color(68, 159, 239);
      break;
    case MOUNTAIN:
      c = color(185, 117, 65);
      break;
    case FOREST:
      c = color(22, 139, 42);
      break;
    default:
    }
    fill(c);
    rect(x, y, tileWidth, tileHeight);
    if (attackRange) {
      strokeWeight(3);
      fill(255, 0, 0, 50);
      stroke(255, 0, 0);
      rect(x+5, y+5, tileWidth-10, tileHeight-10, 0);
      strokeWeight(1);
      stroke(0);
    }
    if (highlighted) {
      fill(255, 127, 0, 128);
      rect(x, y, tileWidth, tileHeight);
    }
  }
}
