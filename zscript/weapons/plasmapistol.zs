class PlasmaPistol : DriftWeapon {
    // Fires a bolt of plasma.
    // Powered off a fuel cell that will live longer than you do,
    // but its power output is limited, so the capacitors need to be
    // filled in order to fire.

    default {
        Weapon.AmmoType1 "Capacitor";
        Weapon.AmmoUse1 1;
        Weapon.SlotNumber 1;
        DriftWeapon.Sway 0.5,1;
        DriftWeapon.Shot "PlasBolt","weapons/plasmaf";
        DriftWeapon.Flip 4,0.5;
    }

    override void DoEffect() {
        if (owner.player.readyweapon is self.GetClassName() && GetAge() % 35 == 0 && !(GetPlayerInput(INPUT_BUTTONS) & BT_ATTACK)) {
            owner.GiveInventory("Capacitor",1);
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
            PISG B 4 Fire();
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