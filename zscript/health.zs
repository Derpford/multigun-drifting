class HealthBottle : Inventory {
    // Holds all your heals.
    // Any overflow healing goes into the HealthBottle, and applies over time.

    int healing; // How much health is available.

    override bool HandlePickup(Inventory it) {
        if (it is "DriftHealth") {
            int maxheals = max(0,owner.GetMaxHealth(true) - owner.health);
            if (it.amount > maxheals) {
                // Take some from its Amount and add it to our healing.
                healing += it.amount - maxheals;
                it.amount = maxheals;
            }
            owner.GiveBody(it.amount);
            it.GoAwayAndDie();
        }

        return false; // In all cases, we return to normal pickup handling.
    }

    override void DoEffect() {
        super.DoEffect();
        if (owner.health < owner.GetMaxHealth(true) && healing > 0 && GetAge() % 5 == 0) {
            owner.GiveBody(1);
            healing--;
        }
    }
}

class DriftHealth : Inventory {
    // Gives as much as it can in one fell swoop. After that, it passes the rest to HealthBottle.
    override bool HandlePickup(Inventory it) {
        // Our pickup handling happens through HealthBottle.
        return false;
    }
}

class DriftMedikit : DriftHealth replaces Medikit {
    default {
        Inventory.Amount 30;
        Inventory.PickupMessage "Got a Medkit.";
    }

    states {
        Spawn:
            MEDI A 6;
            MEDI A 3 Bright;
            Loop;
    }
}

class DriftStim : DriftHealth replaces Stimpack {
    default {
        Inventory.Amount 15;
        Inventory.PickupMessage "Got a Stim.";
    }
    
    states {
        Spawn:
            STIM A 6;
            STIM A 3 Bright;
            Loop;
    }
}