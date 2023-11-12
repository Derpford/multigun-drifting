class Mossberg : DriftWeapon replaces Shotgun {
    // A pump-action shotgun.
    // Drift is slightly wider, but also significantly slower,
    // to match the slower pace of the weapon.

    default {
        DriftWeapon.Sway 1.2,0.5;
        DriftWeapon.Flip 10,1; // Really hard kick!
        Weapon.AmmoType1 "Shell";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 8;
        Weapon.SlotNumber 3;
        DriftWeapon.Shot "MossbergWad","weapons/shotgf"; // Should fire a 'wad' that later unfolds into a set of 8 pellets.
    }

    states {
        Spawn:
            SHOT A -1;
        
        Select:
            SHTG A 1 A_Raise(18);
            Loop;
        DeSelect:
            SHTG A 1 A_Lower(18);
            Loop;

        Ready:
            SHTG A 1 A_WeaponReady();
            Loop;

        Fire:
            SHTG A 3 Fire();
            SHTG B 4;
            SHTG C 5;
            SHTG D 6;
            SHTG CB 4;
        Hold:
            SHTG A 1;
            SHTG A 0 A_Refire();
            Goto Ready; // Semi-auto.
    }
}

class MossbergWad : DriftShot {
    // A tightly-packed wad of pellets that hasn't spread yet.
    default {
        Speed 120;
        DamageFunction (96); // This thing HURTS.
        Radius 3;
        Height 2;
        DriftShot.Drift (1,1),120; // Spreads out pretty quick.
        DriftShot.DriftSpeed 10,20; // Doesn't matter much, since this thing disappears the moment it spawns its submunitions.
    }

    override void DriftEnabled() {
        // Spawns 8 submunitions, then dies.
        console.printf("Spawning submunitions");
        for (int i = 0; i < 8; i++) {
            vector2 spread = RotateVector((frandom(i,i*0.5) * 0.1,0),frandom(0,360));
            let b = Spawn("MossbergPellet",pos);
            b.target = target;
            b.Vel3DFromAngle(vel.length(),angle+spread.x,-(pitch+spread.y));
        }

        SetState(ResolveState("Death"));
    }
}

class MossbergPellet : DriftShot {
    // Does slightly less damage than a single bullet.
    default {
        DamageFunction (10);
        DriftShot.Drift(5,5),0; // Starts drifting right away.
    }
}