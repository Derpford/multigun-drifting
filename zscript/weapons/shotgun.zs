class Mossberg : DriftWeapon replaces SuperShotgun {
    // A pump-action shotgun.
    // Drift is slightly wider, but also significantly slower,
    // to match the slower pace of the weapon.

    default {
        DriftWeapon.Sway 5,5;
        DriftWeapon.Flip 10,1; // Really hard kick!
        Weapon.AmmoType1 "Shell";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 8;
        Weapon.SlotNumber 3;
        Weapon.SlotPriority 2.0;
        DriftWeapon.Shot "MossbergWad","weapons/shotgf"; // Should fire a 'wad' that later unfolds into a set of 8 pellets.
        Inventory.PickupMessage "Got a pump shotgun.";
    }

    action void FireShotty() {
        Fire();
        A_GunFlash();
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
            SHTG A 3 FireShotty();
            SHTG B 3;
            SHTG C 4;
            SHTG D 5;
            SHTG CB 3;
            SHTG A 1 A_Refire();
            Goto Ready;
        
        Flash:
            SHTF ABB 1 Bright;
            Stop;
    }
}

class PackedShot : DriftShot {
    // Contains submunitions!
    Name projectile;
    int projcount;
    Property Submunition: projectile,projcount;
    override void DriftEnabled() {
        for (int i = 0; i < projcount; i++) {
            vector2 spread = RotateVector((frandom(i,i*0.5) * 0.1,0),frandom(0,360));
            let b = Spawn(projectile,pos);
            b.target = target;
            b.tracer = tracer;
            b.master = master; // Transfer all pointers, just in case!
            b.angle = angle;
            b.pitch = pitch; // Also transfer angles, d'oh
            b.Vel3DFromAngle(vel.length()+b.speed,angle+spread.x,-(pitch+spread.y));
        }

        SetState(ResolveState("Spent"));
    }

    states {
        Spent:
            TNT1 A 0;
            Stop;
    }
}

class MossbergWad : PackedShot {
    // A tightly-packed wad of pellets that hasn't spread yet.
    default {
        Speed 120;
        DamageFunction (96); // This thing HURTS.
        Radius 3;
        Height 2;
        PackedShot.Submunition "MossbergPellet",10;
        DriftShot.Drift (1,1),120; // Spreads out pretty quick.
        DriftShot.DriftSpeed 10,20; // Doesn't matter much, since this thing disappears the moment it spawns its submunitions.
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
        DriftWeapon.Sway 2.5,7;
        DriftWeapon.Flip 15,1; // Kicks even harder than the shotgun.
        DriftWeapon.Shot "SawnoffWad","weapons/sshotf";
        Weapon.SlotNumber 3;
        Weapon.SlotPriority 1.0;
        Weapon.AmmoType1 "Shell";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 8;
        Inventory.PickupMessage "Got a sawn-off shotgun.";
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
        if (!which) {
            if (!invoker.chamber1 && invoker.DepleteAmmo(false)) {
                invoker.chamber1 = true;
                Fire(ammo:false,offs:(-2,0));
                return ResolveState(null);
            }
        } else {
            if (!invoker.chamber2 && invoker.DepleteAmmo(false)) {
                invoker.chamber2 = true;
                Fire(ammo:false,offs:(2,0));
                return ResolveState(null);
            }
        }
        // If we get to this point, firing failed.
        return ResolveState("Click");
    }

    action void ShotgunNoises(int which) {
        switch (which) {
            case 0:
                A_StartSound("weapons/sshoto");
                break;
            case 1:
                A_StartSound("weapons/sshotl");
                break;
            case 2:
                A_StartSound("weapons/sshotc");
                break;
            default:
                // No noises!
                break;
        }
        A_WeaponReady(WRF_NOFIRE);
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
        ClickHold:
            SHT2 A 1;
            SHT2 A 0 A_Refire("ClickHold");
            Goto Ready;

        Reload:
            SHT2 A 0 {
                if (A_Overlay(2,"null") && A_Overlay(3,"null")) {
                    return ResolveState(null);
                } else {
                    return ResolveState("Ready");
                }
            }
            SHT2 BC 4 ShotgunNoises(-1);
            SHT2 D 4 ShotgunNoises(0);
            SHT2 E 8 ShotgunNoises(-1);
            SHT2 F 4 ShotgunNoises(1);
            SHT2 G 8 ShotgunNoises(-1);
            SHT2 A 0 ChamberLoad();
            SHT2 H 8 ShotgunNoises(2);
            Goto Ready;
    }
}

class SawnoffWad : MossbergWad {
    // Spreads out immediately.
    default {
        DriftShot.Drift (5,5),0;
        PackedShot.Submunition "SawnoffPellet",10;
    }
}

class SawnoffPellet : MossbergPellet {
    default {
        DriftShot.Drift (15,15),0; // WAY harder drift.
    }
}