class DriftWeapon : Weapon abstract {
    // Contains logic for firing projectiles.

    double swayfactor, swayspeed;
    Property Sway : swayfactor, swayspeed; // How much this weapon is affected by sway!

    double driftfactor;
    Property DriftFac: driftfactor; // How much this weapon's sway is multiplied by while drifting.

    Name projectile; // What this gun fires by default.
    String sound;
    Property Shot: projectile,sound;

    double mflip; // muzzle flip--or, how far down the sprite should be lowered to make it *look* like there's muzzle flip
    double mflipadd, mflipdecay; // how much to add per shot, percentage to remove per second
    Property Flip: mflipadd, mflipdecay;


    default {
        DriftWeapon.Sway 3,10;
        DriftWeapon.Flip 3,1;
        DriftWeapon.Shot "DriftShot","weapons/pistol";
        DriftWeapon.DriftFac 0.3;
    }

    action Actor Fire(Name proj = "null",Vector2 angles = (0,0),bool ammo = true,vector2 offs = (0,0),int flags = 0) {
        if (proj == "null") {proj = invoker.projectile;}
        double ang = 0;
        if (DriftPlayer(invoker.owner)) {
            let dp = DriftPlayer(invoker.owner);
            ang = -dp.sway * invoker.swayfactor;
            invoker.mflip += invoker.mflipadd * (invoker.mflipadd / (invoker.mflip + invoker.mflipadd));
        }

        Actor r1,r2;
        [r1,r2] = A_FireProjectile(proj,angle:ang+angles.x,ammo,offs.x,offs.y,flags,angles.y);
        A_StartSound(invoker.sound,1);
        return r2;
    }

    override void Tick() {
        Super.Tick();
        double mfd = mflip * mflipdecay * 1./35.;
        mflip = max(0,mflip-mfd);
    }

}

class DriftShot : FastProjectile {
    // A single bullet.

    const DT = 1./35.;

    Vector2 drift;
    double range;
    Property Drift: drift,range; // X is left/right magnitude, Y is up/down magnitude,
                                 // range is how far the projectile travels before deviating
                                 // Drift values are per second
    
    bool isDrifting;

    double driftspd; // How fast drifting 'ticks'. Applied as a multiplier to GetAge.
    double driftspdmin, driftspdmax; // A random range to apply to driftspd.
    Property DriftSpeed: driftspdmin, driftspdmax;
                                
    double phase; // Add this to GetAge() to offset the spiral.
    bool spinright; // if true, spin to the right, else spin to the left

    default {
        Projectile;
        DamageFunction(12);
        Radius 2;
        Height 2;
        DriftShot.Drift (5,5),256;
        DriftShot.DriftSpeed 10,20;
        // Gravity 0.05; // Falls very slowly once range is exceeded.
        Speed 120;
        MissileHeight 8;
        MissileType "DriftShotTrail";
    }

    override void PostBeginPlay() {
        // Set this thing's phase and spin.
        phase = frandom(0,360);
        driftspd = frandom(driftspdmin,driftspdmax);
        spinright = (frandom(0,1) > 0.5);
        super.PostBeginPlay();

    }

    virtual void DoDrift() {
        // Called once a tick while drifting.
        double theta = (GetAge() * driftspd) + phase;
        vector2 dir = (-cos(theta),sin(theta)).unit();
        vector2 xdir = RotateVector(vel.xy,90).unit();
        xdir = xdir * dir.x * drift.x * DT;
        if (spinright) {
            vel.xy += xdir;
        } else {
            vel.xy -= xdir;
        }
        vel.z += dir.y * drift.y * DT;
    }

    virtual void DriftEnabled() {
        // Called once when projectile drifting starts.
        // I might use this later to simulate a tightly-packed shotshell starting to spread after a few meters.
        bNOGRAVITY = false;
    }

    override void Tick() {
        Super.Tick();
        // Set the pitch and angle according to our velocity.
        angle = VectorAngle(vel.x,vel.y);
        pitch = VectorAngle(vel.xy.length(),vel.z);

        if (!InStateSequence(curstate, ResolveState("Spawn"))) { return; } // Don't process anything else if we're not alive.

        if (isDrifting) {
            DoDrift();
        }

        // First of all, have we exceeded our range yet?
        range -= vel.length();
        if (range < 0) {
            // Now the meat of the work happens.
            if (!isDrifting) {
                isDrifting = true;
                DriftEnabled();
            }
        }

        if (!bNOGRAVITY) {
            double ln = max(1,vel.length() * 0.1);
            if (ln != ln) ln = 1; // NaN check
            vel.z -= GetGravity() / ln;
        }
    }

    states {
        Spawn:
            TNT1 A 1;
            Loop;
        Death:
            TNT1 A 0;
            Stop;
    }
}

class DriftShotTrail : Actor {
    default {
        +NOINTERACTION;
        RenderStyle "Add";
        Alpha 0.5;
    }

    states {
        Spawn:
            PUFF A 1 A_FadeOut();
            Loop;
    }
}