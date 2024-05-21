class HealthBottle : Inventory {
    // Holds all your heals.
    // Any overflow healing goes into the HealthBottle, and applies over time.

    int healing; // How much health is available.
    int healthtimer; // Increment by healing - playerhealth each tick.
    const htime = 500; // How much healthtimer we need to heal.
    // 500 means that if the player has 100 healing stocked up, and is at 0 health,
    // they heal 1 every 5 ticks.

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
        if (owner.health < owner.GetMaxHealth(true) && healing > 0 ) {
            if(healthtimer >= htime) {
                owner.GiveBody(1);
                healing--;
                healthtimer -= htime;
            } else {
                healthtimer += max(10,healing - owner.health);
                // Absolute worst case scenario, it takes just under 2 seconds to heal 1 hp.
            }
        } else {
            healthtimer = 0; // Reset the healthtimer as long as we have no damage or no healing.
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