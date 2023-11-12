class TestGun : DriftWeapon {
    // Shoots simple projectiles.

    default {
        Weapon.SlotNumber 1;
        DriftWeapon.Sway 0.5,1;
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
            PISG B 3 Fire();
            PISG C 2;
            Goto Ready;
    }
}

class TestShot : Actor {
    default {
        DamageFunction (5);
        Projectile;
        Speed 40;
        +BRIGHT;
    }

    states {
        Spawn:
            PLSS AB 3;
            Loop;
        Death:
            PLSE ABCDE 3;
            Stop;
    }
}

class TestGun2 : DriftWeapon {
    // A weapon with more sway and higher firerate, and also some spread.
    default {
        Weapon.SlotNumber 2;
        DriftWeapon.Sway 1,0.5;
    }
    
    states {
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
            SHTG A 3 Fire("DriftShot",(
                frandom(-2,2),
                frandom(-6,2)
            ));
            SHTG B 4 A_Refire();
            SHTG C 6;
            SHTG B 3;
            Goto Ready; 
    }
}