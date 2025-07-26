import 'package:flame/components.dart';
import '../components/player.dart';

class EnergySystem extends Component {
  // Energy configuration
  static const double maxEnergy = 1.0;
  static const double energyPerSeed = 0.25;
  static const double energyDecayRate = 0.05; // Energy decay per second when idle
  static const double energyRequiredToRoll = 1.0;
  
  // Seed planting configuration
  static const double seedPlantingCooldown = 1.0; // Seconds between seed planting
  double lastSeedPlantTime = 0.0;
  
  // Energy regeneration
  bool isRegenerating = false;
  double regenerationRate = 0.1; // Energy per second during regeneration
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update seed planting cooldown
    if (lastSeedPlantTime > 0) {
      lastSeedPlantTime -= dt;
      if (lastSeedPlantTime < 0) {
        lastSeedPlantTime = 0;
      }
    }
  }
  
  bool canPlantSeed() {
    return lastSeedPlantTime <= 0;
  }
  
  void plantSeed(Player player) {
    if (!canPlantSeed()) return;
    
    // Add energy
    player.energy += energyPerSeed;
    
    // Clamp energy to maximum
    if (player.energy > maxEnergy) {
      player.energy = maxEnergy;
    }
    
    // Set cooldown
    lastSeedPlantTime = seedPlantingCooldown;
    
    // Visual feedback
    player.showEnergyGain();
  }
  
  bool canRollDice(Player player) {
    return player.energy >= energyRequiredToRoll;
  }
  
  void consumeEnergyForRoll(Player player) {
    if (canRollDice(player)) {
      player.energy = 0.0; // Reset energy after rolling
    }
  }
  
  void startRegeneration(Player player) {
    isRegenerating = true;
  }
  
  void stopRegeneration() {
    isRegenerating = false;
  }
  
  void updateRegeneration(Player player, double dt) {
    if (isRegenerating && player.energy < maxEnergy) {
      player.energy += regenerationRate * dt;
      if (player.energy > maxEnergy) {
        player.energy = maxEnergy;
        stopRegeneration();
      }
    }
  }
  
  void applyEnergyDecay(Player player, double dt) {
    // Optional: Apply energy decay when idle
    // This can make the game more challenging
    if (player.energy > 0 && !isRegenerating) {
      player.energy -= energyDecayRate * dt;
      if (player.energy < 0) {
        player.energy = 0;
      }
    }
  }
  
  void addBonusEnergy(Player player, double amount) {
    player.energy += amount;
    if (player.energy > maxEnergy) {
      player.energy = maxEnergy;
    }
    player.showEnergyGain();
  }
  
  void removeEnergy(Player player, double amount) {
    player.energy -= amount;
    if (player.energy < 0) {
      player.energy = 0;
    }
    player.showDamage();
  }
  
  double getEnergyPercentage(Player player) {
    return player.energy / maxEnergy;
  }
  
  String getEnergyStatus(Player player) {
    double percentage = getEnergyPercentage(player) * 100;
    
    if (percentage >= 100) {
      return 'Full Energy - Ready to roll!';
    } else if (percentage >= 75) {
      return 'High Energy';
    } else if (percentage >= 50) {
      return 'Medium Energy';
    } else if (percentage >= 25) {
      return 'Low Energy';
    } else {
      return 'No Energy - Plant seeds!';
    }
  }
  
  void reset() {
    lastSeedPlantTime = 0.0;
    isRegenerating = false;
  }
}
