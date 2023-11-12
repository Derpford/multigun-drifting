class UMP45 : DriftWeapon {
    // A PDW with a high rate of fire, and a correspondingly high damage output.
    // However, it has a wider sway than your plasma pistol, and it's harder to control.

    default {
        Weapon.SlotNumber 2;
        DriftWeapon.Sway 1,1;
        Weapon.AmmoType1 "Clip";
        Weapon.AmmoUse1 1;
        DriftWeapon.Flip 4,0.75;
        DriftWeapon.Shot "UMPShot","ump/fire";
    }

    states {
        Select:
            UMP4 FED 2 A_Raise(16);
            Loop;
        DeSelect:
            UMP4 DEF 2 A_Lower(16);
            Loop;

        Ready:
            UMP4 A 1 A_WeaponReady();
            Loop;
        
        Fire:
            UMP4 B 1 Bright {
                double rmax = invoker.mflip / 20.;
                vector2 ang = (frandom(-rmax,rmax),frandom(-rmax*0.5,rmax*0.5));
                Fire(angles:ang);
            }
            UMP4 CA 1;
            Goto Ready;
    }
}

class UMPShot : DriftShot {
    default {
        DamageFunction (22);
    }
}