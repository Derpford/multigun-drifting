class DriftWeapon : Weapon abstract {
    // Contains logic for firing projectiles.

    double swayfactor;
    Property Sway : swayfactor; // How much this weapon is affected by sway!

    default {
        DriftWeapon.Sway 1;
    }

    action void Fire(Name proj,Vector2 angles = (0,0),bool ammo = true,vector2 offs = (0,0),int flags = 0) {
        double ang = 0;
        if (DriftPlayer(invoker.owner)) {
            let dp = DriftPlayer(invoker.owner);
            ang = -dp.sway * invoker.swayfactor;
        }

        A_FireProjectile(proj,angle:ang+angles.x,ammo,offs.x,offs.y,flags,angles.y);
    }

}