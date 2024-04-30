class PulseRifle : DriftWeapon replaces PlasmaRifle {
    // Sprays plasma everywhere.
    // Fires more powerful plasma than the plasma pistol, but eats actual ammo.
    // Shots have some vertical spread.

    double heat;
    double steamtic;

    default {
        DriftWeapon.Shot "PRShot","weapons/plasmaf";
        DriftWeapon.Sway 6,11;
        DriftWeapon.Flip 14, 5;
        Weapon.SlotNumber 4;
        Weapon.AmmoType1 "Cell";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 50;
        Inventory.PickupMessage "Got a Pulse Rifle.";
    }

    action void FirePRifle(double vert) {
        Fire(angles:(0,vert));
        invoker.heat += 1.5;
        PRifleCool();
    }

    action void PRifleCool(int m = 2) {
        // PRifle takes longer between shots as it heats up.
        A_SetTics(max(m,log(1+invoker.heat)));
    }

    override void Tick() {
        Super.Tick();
        double heatdrate = 30. / (30.+heat);
        double heatdelta = max(5.0,15.0 * heatdrate);
        heat = max(0.0,heat - (heatdelta * 1./35.));
        steamtic += heat;
        if (steamtic > 35) {
            double vx = (owner) ? 10 : frandom(-3,3);
            Actor it = owner; if (!it) it = self;
            it.A_SpawnParticle("White",SPF_RELANG|SPF_RELVEL,35,log(1+heat),velx:vx,vely:frandom(-3,3),velz:frandom(-1,5),accelz:0.1,sizestep:3);
            steamtic -= 35;
        }
    }

    states {
        Spawn:
            PLAS A -1;

        Select:
            PLSG B 1 A_Raise(12);
            Loop;
        DeSelect:
            PLSG B 1 A_Lower(12);
            Loop;
        
        Ready:
            PLSG A 1 A_WeaponReady();
            Loop;
        
        Fire:
            PLSG A 2 FirePRifle(0);
            PLSG A 2 FirePRifle(-0.25);
            PLSG A 2 FirePRifle(-0.5);
            PLSG A 2 PRifleCool(0);
            Goto Ready;
    }
}

class PRShot: PlasBolt {
    default {
        DamageFunction (24);
    }
}