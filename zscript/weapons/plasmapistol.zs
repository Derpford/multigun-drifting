class PlasmaPistol : DriftWeapon replaces Chainsaw {
    // Fires a bolt of plasma.
    // Powered off a fuel cell that will live longer than you do,
    // but its power output is limited, so the capacitors need to be
    // filled in order to fire.

    int shots;
    Property StartShots: shots;

    default {
        Weapon.AmmoType1 "Capacitor";
        Weapon.AmmoUse1 1;
        Weapon.SlotNumber 1;
        DriftWeapon.Sway 1.5,10;
        DriftWeapon.Shot "PlasBolt","weapons/plasmaf";
        DriftWeapon.Flip 4,0.5;
        DriftWeapon.DriftFac 0.1; // Much more useful while drifting!
        PlasmaPistol.StartShots 1;
        Inventory.PickupMessage "Got a plasma sidearm.";
    }

    override String PickupMessage() {
        if (bAMBUSH) return "Scrapped a plasma sidearm. (Plasma Pistol upgraded!)";
        else return pickupmsg;
    }

    override void DoEffect() {
        if (GetAge() % 35 == 0 && !(GetPlayerInput(INPUT_BUTTONS) & BT_ATTACK)) {
            owner.GiveInventory("Capacitor",1);
        }
    }

    override bool HandlePickup(Inventory other) {
        // Picking up duplicate plasma sidearms increases the capacitor's...capacity,
        // and also increases the power/ammo usage of your shots.
        if (other is self.GetClass()) {
            other.bPICKUPGOOD = true;
            other.bAMBUSH = true; // Used to indicate that the other item was picked up for scrap.
            int cap = owner.GetAmmoCapacity("Capacitor");
            owner.SetAmmoCapacity("Capacitor",cap+10);
            shots++;
            return true;
        }
        return false;
    }

    action void FirePistol() {
        for (int i = 0; i < invoker.shots; i++) {
            Fire();
        }
    }

    states {
        Spawn:
            PIST A -1;
        
        Select:
            PISG A 1 A_Raise(18);
            Loop;
        DeSelect:
            PISG A 1 A_Lower(18);
            Loop;

        Ready:
            PISG A 1 A_WeaponReady();
            Loop;
        
        Fire:
            PISG B 4 FirePistol();
            PISG C 3;
            PISG C 0 A_Refire();
            Goto Ready;
    }
}

class PlasBolt : DriftShot {
    default {
        Radius 4;
        Height 4;

        MissileType "PlasTrail";
    }

    override void DriftEnabled() {
        // Empty, because gravity doesn't work that way with plasma.
    }

    override void DoDrift() {
        double dv = (vel.length() * 0.1) * 1./35.;
        vel = vel.unit() * (vel.length() - dv);
        if (vel.length() < 60) {
            // Time to stop.
            SetState(ResolveState("Death"));
        }
        super.DoDrift();
    }
}

class PlasTrail : DriftShotTrail {
    default {
        Scale 0.3;
    }

    states {
        Spawn:
            PLSE ABCDE 2;
            Stop;
    }
}

class Capacitor : Ammo {
    default {
        Inventory.Icon "CELLA0";
        Inventory.Amount 1;
        Inventory.MaxAmount 20;
    }
}