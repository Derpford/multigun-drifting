class DriftArmor : Armor {
    int saveamount;
    int maxfullabsorb;
    double savepercent;
    Property SaveAmount: saveamount;
    Property FlatAbsorb: maxfullabsorb;
    Property SavePercent: savepercent;
    default {
        Inventory.MaxAmount 2;
        Inventory.Amount 1;
        DriftArmor.SaveAmount 150;
        DriftArmor.SavePercent 0.5;
        DriftArmor.FlatAbsorb 20;
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
            saveamount = GetDefaultByType(GetClass()).saveamount;
            owner.TakeInventory(self.GetClassName(),1);
        }
    }
}

class DriftGreenArmor : DriftArmor replaces GreenArmor {
    // A set of plates for your plate carrier.
    default {
        Inventory.PickupMessage "Got a steel armor plate.";
        DriftArmor.SaveAmount 75;
        DriftArmor.FlatAbsorb 10; // Takes bullets with relative ease.
    }

    states {
        Spawn:
            ARM1 A 3;
            ARM1 B 3 Bright;
            Loop;
    }

}

class DriftBlueArmor : DriftArmor replaces BlueArmor {
    // A ceramic plate for your plate carrier. Blocks a larger chunk of initial damage.
    default {
        Inventory.PickupMessage "Got a ceramic armor plate.";
        DriftArmor.SaveAmount 150;
        DriftArmor.FlatAbsorb 60; // Wears out pretty fast, to be honest...
    }

    states {
        Spawn:
            ARM2 A 3;
            ARM2 B 3 Bright;
            Loop;
    }
}