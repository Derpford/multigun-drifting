class DriftWeapon : Weapon abstract {
    // Contains logic for firing projectiles.

    double swayfactor;
    Property Sway : swayfactor; // How much this weapon is affected by sway!

    Name projectile; // What this gun fires by default.
    Property Shot: projectile;

    default {
        DriftWeapon.Sway 1;
        DriftWeapon.Shot "DriftShot";
    }

    action void Fire(Name proj = "null",Vector2 angles = (0,0),bool ammo = true,vector2 offs = (0,0),int flags = 0) {
        if (proj == "null") {proj = invoker.projectile;}
        double ang = 0;
        if (DriftPlayer(invoker.owner)) {
            let dp = DriftPlayer(invoker.owner);
            ang = -dp.sway * invoker.swayfactor;
        }

        A_FireProjectile(proj,angle:ang+angles.x,ammo,offs.x,offs.y,flags,angles.y);
    }

}

class DriftShot : Actor {
    // A single bullet.

    const DT = 1./35.;

    Vector2 drift;
    double range;
    Property Drift: drift,range; // X is left/right magnitude, Y is up/down magnitude,
                                 // range is how far the projectile travels before deviating
                                 // Drift values are per second
    
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
        DriftShot.Drift (5,5),512;
        DriftShot.DriftSpeed 10,20;
        Gravity 0.05; // Falls very slowly once range is exceeded.
        Speed 60;
    }

    override void PostBeginPlay() {
        // Set this thing's phase and spin.
        phase = frandom(0,360);
        driftspd = frandom(driftspdmin,driftspdmax);
        spinright = (frandom(0,1) > 0.5);
        super.PostBeginPlay();

    }

    override void Tick() {
        Super.Tick();

        // First of all, have we exceeded our range yet?
        if (range > 0) {
            range -= vel.length();
        } else {
            // Now the meat of the work happens.
            bNOGRAVITY = false;
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
    }

    states {
        Spawn:
            PUFF A 1;
            Loop;
        Death:
            TNT1 A 0;
            Stop;
    }
}