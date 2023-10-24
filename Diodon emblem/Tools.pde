class Tool {
  String name;
  int efficiency, range, durability;
  // int precison; // Value from 0 to 100

  public Tool(String toolName, int toolEfficiency, int toolRange) {
    name = toolName;
    efficiency = toolEfficiency;
    range = toolRange;

    durability = 100;
  }
}

class Weapon extends Tool {
  // int criticalChance; //Value from 0 to 100

  public Weapon(String weaponName, int weaponDamage, int weaponRange) {
    super(weaponName, weaponDamage, weaponRange);
  }
}

class PhysicalWeapon extends Weapon {
  PhysicalWeaponType type;

  PhysicalWeapon(String weaponName, int weaponDamage, int weaponRange, PhysicalWeaponType weaponType) {
    super(weaponName, weaponDamage, weaponRange);

    type = weaponType;
  }
}

class MagicalWeapon extends Weapon {
  MagicalWeaponType type;

  MagicalWeapon(String weaponName, int weaponDamage, int weaponRange, MagicalWeaponType weaponType) {
    super(weaponName, weaponDamage, weaponRange);

    type = weaponType;
  }
}

class Staff extends Tool {
  public Staff(String staffName, int staffEfficiency, int staffRange) {
    super(staffName, staffEfficiency, staffRange);
  }
}

enum PhysicalWeaponType {
  Sword, Spear, Axe, Bow
}

enum MagicalWeaponType {
  Fire, Ice, Thunder, Wind, Light, Dark
}

// enum staffType : heal, buff, debuff ...
