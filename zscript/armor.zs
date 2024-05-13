class DriftArmor : Armor {
    int saveamount;
    int savemax;
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
        DriftArmor.FlatAbsorb 20;
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
        // Finally, subtract absorbed from our saveamount. If saveamount <= 0, reset it to default and take one plate.
        saveamount -= absorbed;
        if (saveamount <= 0) {
            saveamount = savemax;
            owner.TakeInventory(self.GetClassName(),1);
        }
    }
}

class DriftGreenArmor : DriftArmor replaces GreenArmor {
    // A set of plates for your plate carrier.
    default {
        Inventory.PickupMessage "Got a steel armor plate.";
        DriftArmor.SaveAmount 200;
        DriftArmor.FlatAbsorb 10; // Takes bullets with relative ease.
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
        DriftArmor.SaveAmount 100;
        DriftArmor.FlatAbsorb 60; // Wears out pretty fast, to be honest...
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