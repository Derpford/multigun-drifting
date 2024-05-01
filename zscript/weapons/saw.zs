class SquadAutoWeapon : DriftWeapon replaces Chaingun {
    // Big, beefy, and designed for fighting from an emplaced position.
    // Heavy sway and chews through ammo extremely fast, but it eats through enemies even faster.

    default {
        Weapon.SlotNumber 2; // Shares ammo, and a slot, with the UMP45.
        Weapon.AmmoType1 "Clip";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 60;
        DriftWeapon.Sway 3.5,2;
        DriftWeapon.Flip 2,1;
        DriftWeapon.Shot "SAWShot","weapons/m60f";
        Inventory.PickupMessage "Got the Squad Automatic Weapon!";
    }

    action void FireSAW() {
        double rmax = max(1.2,0.6 + invoker.mflip) * 0.5;
        vector2 ang = (frandom(-rmax,rmax),0);
        Fire(angles:ang);
        Fire(angles:ang * 0.3); // Two bullets at once, because reasons!
        A_GunFlash();
    }

    states {
        Spawn:
            MGUN A -1;

        Select:
            CHGG AB 4 A_Raise(12);            
            Loop;
        DeSelect:
            CHGG AB 4 A_Lower(12);            
            Loop;
        
        Ready:
            CHGG A 1 A_WeaponReady();
            Loop;
        
        Fire:
            CHGG A 2 FireSAW();
            CHGG B 2;
            CHGG A 2 FireSAW();
            CHGG B 2;
            CHGG AB 2 A_Refire();
            CHGG A 0 A_StartSound("weapons/sshoto");
            CHGG AB 3 A_Refire();
            CHGG A 0 A_StartSound("weapons/sshoto");
            CHGG AB 4 A_Refire();
            CHGG A 0 A_StartSound("weapons/sshoto");
            CHGG AB 6 A_Refire();
            CHGG A 0 A_StartSound("weapons/sshoto");
            Goto Ready;

        Flash:
            CHGF A Random(0,2) A_Light1();
            CHGF B Random(0,2) A_Light2();
            Stop;
    }
}

class SAWShot : UMPShot {
    default {
        DamageFunction (18); // Slightly more powerful.
        DriftShot.Drift (8,8),512; // Drifts from further out, but drifts harder.
    }
}