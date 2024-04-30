class UMP45 : DriftWeapon replaces Pistol {
    // A PDW with a high rate of fire, and a correspondingly high damage output.
    // However, it has a wider sway than your plasma pistol, and it's harder to control.

    default {
        Weapon.SlotNumber 2;
        DriftWeapon.Sway 4,10;
        Weapon.AmmoType1 "Clip";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 60;
        DriftWeapon.Flip 12,3;
        DriftWeapon.Shot "UMPShot","ump/fire";
        Inventory.PickupMessage "Got a UMP45.";
    }

    action void FireUMP() {
        double rmax = invoker.mflip / 20.;
        vector2 ang = (frandom(-rmax,rmax),frandom(-rmax*0.5,rmax*0.5));
        Fire(angles:ang);
    }


    states {
        Select:
            UMP4 F 2 A_Raise(16);
            Loop;
        DeSelect:
            UMP4 F 2 A_Lower(16);
            Loop;

        Ready:
            UMP4 A 1 A_WeaponReady();
            Loop;
        
        Fire:
            UMP4 B 1 Bright FireUMP();
            UMP4 CA 1;
            Goto Ready;
    }
}

class UMPShot : DriftShot {
    default {
        DamageFunction (12);
    }
}