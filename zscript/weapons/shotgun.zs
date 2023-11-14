class Mossberg : DriftWeapon replaces SuperShotgun {
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
            SHTG B 3;
            SHTG C 4;
            SHTG D 5;
            SHTG CB 3;
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
        for (int i = 0; i < 10; i++) {
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
        DamageFunction (9);
        DriftShot.Drift(5,5),0; // Starts drifting right away.
    }
}

class SawnOff : DriftWeapon replaces Shotgun {
    // No choke. Practically no barrel either.

    bool chamber1,chamber2;

    default {
        DriftWeapon.Sway 0.6,1.0;
        DriftWeapon.Flip 15,1; // Kicks even harder than the shotgun.
        DriftWeapon.Shot "SawnoffWad","weapons/sshotf";
        Weapon.SlotNumber 3;
        Weapon.AmmoType1 "Shell";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 8;
    }

    action state ChamberCheck() {
        if (invoker.chamber1 && invoker.chamber2) {
            // Both chambers fired. Jump to reload automatically.
            return invoker.ResolveState("Reload");
        } else {
            return invoker.ResolveState(null);
        }
    }

    action void ChamberLoad() {
        // Load both chambers.
        invoker.chamber1 = false; invoker.chamber2 = false;
    }

    action state FireChamber(bool which) { // if false, fires chamber1. Otherwise, fires chamber2.
        if (which) {
            if (!invoker.chamber1 && invoker.DepleteAmmo(false)) {
                invoker.chamber1 = true;
                Fire(offs:(2,0));
                return ResolveState(null);
            }
        } else {
            if (!invoker.chamber2 && invoker.DepleteAmmo(false)) {
                invoker.chamber2 = true;
                Fire(offs:(-2,0));
                return ResolveState(null);
            }
        }
        // If we get to this point, firing failed.
        return ResolveState("Click");
    }

    states {
        Spawn:
            SGN2 A -1;
            Stop;
        
        Select:
            SHT2 A 1 A_Raise(18);
            Loop;
        DeSelect:
            SHT2 A 1 A_Lower(18);
            Loop;
        
        Ready:
            SHT2 A 0 ChamberCheck();
            SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;

        Fire:
            SHT2 A 0 FireChamber(false);
            SHT2 A 0 A_Overlay(2,"FlashLeft");
            SHT2 A 6 A_WeaponReady(WRF_NOPRIMARY);
            Goto Ready;
        
        FlashLeft:
            SH2F ABA 2 Bright;
            Stop;
        
        AltFire:
            SHT2 A 0 FireChamber(true);
            SHT2 A 0 A_Overlay(3,"FlashRight");
            SHT2 A 6 A_WeaponReady(WRF_NOSECONDARY);
            Goto Ready;
        
        FlashRight:
            SH2F CDC 2 Bright;
            Stop;
        
        Click:
            SHT2 A 2 A_StartSound("weapons/sshotc");
        Hold:
            SHT2 A 1;
            SHT2 A 0 A_Refire();
            Goto Ready;

        Reload:
            SHT2 A 0 {
                if (A_Overlay(2,"null") && A_Overlay(3,"null")) {
                    return ResolveState(null);
                } else {
                    return ResolveState("Ready");
                }
            }
            SHT2 BC 6;
            SHT2 D 6 A_StartSound("weapons/sshoto");
            SHT2 E 6;
            SHT2 F 6 A_StartSound("weapons/sshotl");
            SHT2 G 5;
            SHT2 H 5 A_StartSound("weapons/sshotc");
            SHT2 A 0 ChamberLoad();
            Goto Ready;
    }
}

class SawnoffWad : MossbergWad {
    // Spreads out immediately.
    default {
        DriftShot.Drift (5,5),0;
    }
}