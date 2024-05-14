class DriftArmor : Armor {
    int saveamount;
    int savemax;
    int recentdmg; // PRNG for armor breaking
    int durabilityCheck; // How high does the roll have to be in order to reduce durability?
    Property DurCheck: durabilityCheck;
    int maxfullabsorb;
    double savepercent;
    Property SaveAmount: savemax;
    Property FlatAbsorb: maxfullabsorb;
    Property SavePercent: savepercent;
    default {
        Inventory.MaxAmount 2;
        Inventory.Amount 1;
        DriftArmor.SaveAmount 150;
        DriftArmor.SavePercent 0.5;
        DriftArmor.FlatAbsorb 0;
        DriftArmor.DurCheck 50;
    }

    override void PostBeginPlay() {
        super.PostBeginPlay();
        saveamount = savemax;
    }

    override bool HandlePickup(Inventory other) {
        if (other is self.GetClass()) {
            // Specifically when picking up a duplicate...
            if (amount == maxamount && saveamount < savemax) {
                // If we can't pick up any more, cannibalize the duplicate to fix this one up.
                saveamount = savemax;
                other.bPICKUPGOOD = true;
                return true; // It's handled.
            }
        }
        return super.HandlePickup(other);
    }

    override void AbsorbDamage (int dmg, Name mod, out int newdmg, Actor inf, Actor src, int flags) {
        int absorbed;
        newdmg = dmg;
        // First, full absorption.
        int fullabs = min(newdmg,maxfullabsorb);
        absorbed += fullabs;
        newdmg -= fullabs;
        // Next, partial absorption.
        // double mult = double(savepercent) / 100.;
        int partabs = ceil(double(newdmg) * savepercent); // 1-point ticks are fully absorbed, Q2-style
        absorbed += partabs;
        newdmg -= partabs;
        // Finally, check armor depletion. If saveamount <= 0, reset it to default and take one plate.
        if (frandom(0,absorbed)+recentdmg > durabilitycheck * (double(saveamount)/double(savemax))) {
            // Essentially: more damage means higher, but not guaranteed, chance of doing durability damage.
            // Lower current durability means higher chance of passing the check.
            saveamount -= ceil(absorbed/10.);
            if (saveamount <= 0) {
                saveamount = savemax;
                owner.TakeInventory(self.GetClassName(),1);
            }
        } else {
            recentdmg += dmg; 
        }
    }

    override void Tick() {
        Super.Tick();
        recentdmg = max(0,recentdmg--);
    }
}

class DriftGreenArmor : DriftArmor replaces GreenArmor {
    // A set of plates for your plate carrier.
    default {
        Inventory.PickupMessage "Got a steel armor plate.";
        DriftArmor.SaveAmount 100;
        DriftArmor.SavePercent 0.4;
        DriftArmor.DurCheck 75;
    }

    states {
        Spawn:
            ARM1 A 6;
            ARM1 B 3 Bright;
            Loop;
    }

}

class DriftBlueArmor : DriftArmor replaces BlueArmor {
    // A ceramic plate for your plate carrier. Blocks a larger chunk of initial damage.
    default {
        Inventory.PickupMessage "Got a ceramic armor plate.";
        DriftArmor.SaveAmount 50;
        DriftArmor.SavePercent 0.6;
        DriftArmor.DurCheck 20;
    }

    states {
        Spawn:
            ARM2 A 6;
            ARM2 B 3 Bright;
            Loop;
    }
}

class ArmorRepairBonus : Inventory replaces ArmorBonus {
    // Slowly restores your current armor, prioritizing steel.

    default {
        Inventory.Amount 3;
        Inventory.MaxAmount 1000; // For all intents and purposes, you'll probably never hit this cap.
        Inventory.PickupMessage "Got an armor repair bonus.";
    }

    override void DoEffect() {
        Super.DoEffect();
        if (amount > 0 && GetAge() % 5 == 0) {

            DriftArmor arm1 = DriftArmor(owner.FindInventory("DriftGreenArmor"));
            DriftArmor arm2 = DriftArmor(owner.FindInventory("DriftBlueArmor"));

            if (arm1 && arm1.saveamount < arm1.savemax) {
                arm1.saveamount++;
                amount--;
            } else if (arm2 && arm2.saveamount < arm2.savemax) {
                arm2.saveamount++;
                amount--;
            }
        }
    }

    states {
        Spawn:
            BON2 ABCDCB 3;
            Loop;
    }
}

class DriftMega : Megasphere replaces Megasphere {
    states {
        Pickup:
            TNT1 A 0 A_GiveInventory("ArmorRepairBonus",200);
            TNT1 A 0 A_GiveInventory("MegasphereHealth",1);
    }
}