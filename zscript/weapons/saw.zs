class SquadAutoWeapon : DriftWeapon replaces Chaingun {
    // Big, beefy, and designed for fighting from an emplaced position.
    // Heavy sway and chews through ammo extremely fast, but it eats through enemies even faster.

    default {
        Weapon.SlotNumber 2; // Shares ammo, and a slot, with the UMP45.
        Weapon.AmmoType1 "Clip";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 60;
        DriftWeapon.Sway 1,1.1;
        DriftWeapon.Flip 3,1;
        DriftWeapon.Shot "UMPShot","weapons/m60f";
    }

    action void FireSAW() {
        double rmax = max(0.3,10 - invoker.mflip) * 0.5;
        vector2 ang = (frandom(-rmax,rmax),0);
        Fire(angles:ang);
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
            CHGG ABAB 2 FireSAW();
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
            CHGF A Random(0,1) A_Light1();
            CHGF B Random(0,1) A_Light2();
            Stop;
    }
}