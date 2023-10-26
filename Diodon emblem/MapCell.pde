
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

  MapCell(CellType tileType, float w, float h, int ix, int iy) {
    type = tileType;
    //tileSize = size;
    tileHeight = h;
    tileWidth = w;
    highlighted = false;
    idX = ix;
    idY = iy;
  }

  void draw(float x, float y) {
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