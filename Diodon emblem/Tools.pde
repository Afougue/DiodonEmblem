class Tool {
}

class Weapon extends Tool {
  int damage;
  int range;
  int durability;
  
  public Weapon(int weaponDamage, int weaponRange) {
    damage = weaponDamage;
    range = weaponRange;
  }
}

class PhysicalWeapon extends Weapon {
  PhysicalWeaponType type;
  
  PhysicalWeapon(int weaponDamage, int weaponRange, PhysicalWeaponType weaponType) {
    super(weaponDamage, weaponRange);
    
    type = weaponType;
  }  
}

class MagicalWeapon extends Weapon {
  MagicalWeaponType type;
  
  MagicalWeapon(int weaponDamage, int weaponRange, MagicalWeaponType weaponType) {
    super(weaponDamage, weaponRange);
    
    type = weaponType;
  }  
}

class Staff extends Tool {
}

enum PhysicalWeaponType {
  Sword, Spear, Axe, Bow
}

enum MagicalWeaponType {
  Fire, Ice, Thunder, Wind, Light, Dark
}
