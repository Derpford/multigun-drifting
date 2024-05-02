class RPG : DriftWeapon replaces RocketLauncher {
    // Thoomp-PFWSSH.
    // Rockets are lobbed a short distance, then accelerate rapidly.

    Actor laser;

    default {
        DriftWeapon.Shot "RocketLobbed","weapons/rocklf";
        DriftWeapon.Sway 4,2;
        DriftWeapon.Flip 20,1;
        DriftWeapon.DriftFac 0.5;
        Weapon.SlotNumber 5;
        Weapon.AmmoType1 "RocketAmmo";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 3;
        Inventory.PickupMessage "Found a laser-guided RPG launcher.";
    }

    action void FireRPG() {
        let rkt = Fire(angles:(0,-16));
        rkt.tracer = invoker.laser;
    }

    override void DoEffect() {
        super.DoEffect();
        if (owner.player.readyweapon is self.GetClass()) {
            // Laser pointer!
            let p = DriftPlayer(owner); if (p) {
                double ang = p.angle - (p.sway * swayfactor);
                FLineTraceData d;
                double zoff = p.height * 0.5 - p.floorclip + p.AttackZOffset*p.player.crouchFactor;
                p.LineTrace(ang,4096,p.pitch,offsetz:zoff,data:d);
                if (!laser) {
                    laser = Spawn("RPGLaser",d.HitLocation);
                } else {
                    laser.SetOrigin(d.HitLocation,false);
                }
            }
        } else if (laser) {
            laser.Die(laser,laser);
        }
    }

    states {
        Spawn:
            LAUN A -1;
        
        Select:
            MISG A 1 A_Raise(10);
            Loop;
        DeSelect:
            MISG A 1 A_Lower(10);
            Loop;
        
        Ready:
            MISG A 1 A_WeaponReady();
            Loop;
        Fire:
            MISG B 8 FireRPG();
            MISG A 8;
            Goto Ready;
    }
}

class RPGLaser : Actor {
    // Warps to where the RPG is pointed at.

    default {
        Scale 0.2;
        RenderStyle "AddStencil";
        StencilColor "Red";
        +NOGRAVITY;
    }

    states {
        Spawn:
            PLSS AB 2;
            Loop;
    }
}

class RocketLobbed : PackedShot {
    default {
        -NOGRAVITY; // Starts with gravity!
        DriftShot.Drift (0,0),256;
        DamageFunction (30); // Big and painful.
        Speed 15;
        Gravity 0.8;
        Radius 16;
        Height 16;
        DriftShot.DriftSpeed 0,0; // Doesn't drift or tumble.
        PackedShot.Submunition "RocketFired",1;
        MissileType "";
    }

    override void Tick() {
        Super.Tick();
        A_Face(tracer);
    }

    states {
        Spawn:
            MISL A 1;
            Loop;
        Death:
            MISL A 5;
            MISL A 0 A_SpawnItemEX("DudRocket");
            Goto Spent;

    }
}

class DudRocket : RocketAmmo {
    states {
        Spawn:
            MISL A -1;
            Stop;
    }
}

class RocketFired : DriftShot {
    default {
        DamageFunction (96);
        Speed 20;
        MissileHeight 12;
        Radius 16;
        Height 16;
        DriftShot.Drift (5,5),1024;
        MissileType "RPGTrail";
        DeathSound "weapons/rocklx";
    }

    double MapRange(double input, Vector2 inrange, Vector2 outrange) {
        return outrange.x + ((outrange.y - outrange.x) / (inrange.y - inrange.x)) * (input - inrange.x);
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        if (tracer) {
            vel = vel.length() * Vec3To(tracer).unit();
        }
    }

    void MissileAccel() {
        // vel = vel.unit() * vel.length() * 1.01;
        // Find our player's current aim point.
        if (tracer) {
            vector3 to = Vec3To(tracer);
            double mult = (vel.unit() dot to.unit());
            mult = MapRange(mult,(1,0),(1.1,10));
            console.printf("vel multiplier: %0.1f",mult);
            vel += to.unit() * mult * vel.length() * 1./35.;
        } else {
            vel += vel.unit() * 1 * 1./35.;
        }
    }

    action void Expand() {
        invoker.scale = invoker.scale * 1.1;
    }

    states {
        Spawn:
            MISL A 1 MissileAccel();
            Loop;
        
        Death:
            MISL B 1 Bright A_Explode(128);
            MISL BBBBBCCCCDDD 1 Bright Expand();
            Stop;
    }
}

class RPGTrail : DriftShotTrail {
    default {
        +BRIGHT;
    }
    states {
        Spawn:
            TNT1 A 2;
            BAL1 C 1;
            TNT1 A 1;
            BAL1 D 1;
            TNT1 A 2;
            BAL1 E 1;
            PUFF CD 6;
            Stop;
    }
}