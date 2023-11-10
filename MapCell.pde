
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
  PImage sprite;

  MapCell(CellType tileType, float w, float h, int ix, int iy) {
    type = tileType;
    //tileSize = size;
    tileHeight = h;
    tileWidth = w;
    highlighted = false;
    idX = ix;
    idY = iy;
    if (tileType == CellType.GRASS){
      sprite = loadImage("data/map/grass_2.png");;
    }else {
      sprite = loadImage("data/map/mountain_1.png");
    }
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
  
  ArrayList<PVector> getPathRecursive(ArrayList<PVector> oldPath){
    oldPath.add(0,new PVector(lastX + tileWidth/2, lastY + 5 * tileHeight/6 ));
    if (previous == null){
      return oldPath;
    }
    return previous.getPathRecursive(oldPath);
  }
    
  ArrayList<PVector> getPath(){
    return getPathRecursive(new ArrayList<PVector>());
  }

  void draw(float x, float y) {
    lastX = x;
    lastY = y;
    image(sprite,x,y);
    if (attackRange) {
      strokeWeight(3);
      fill(255, 0, 0, 50);
      stroke(255, 0, 0);
      rect(x+5, y+5, tileWidth-10, tileHeight-10, 0);
      strokeWeight(1);
    }
    if (highlighted) {
      noStroke();
      fill(255, 127, 0, 128);
      rect(x, y, tileWidth, tileHeight);
    }
    stroke(0);
  }
  
  PVector getCharacterPos(){
    return new PVector(lastX + tileWidth/2,lastY + 5 * tileHeight/6 );
  }
}
