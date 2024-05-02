class GlanceBrain : Inventory {
    // Handles modifying damage based on the angle at which an attack connected.
    const DIRECT = 175.;
    const GLANCE = 135.;
    const LOWDMG = 0.5;
    const HIDMG = 2.0;
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
    }

    override void ModifyDamage(int dmg, name type, out int newdmg, bool passive, Actor inf, Actor src, int flags) {
        // Only run this once.
        if (!passive) {return;}
        // If there's no inflictor or source, don't modify the damage.
        // Likewise, if this is explosive damage (i.e., Vile fire), don't bother.
        if ((flags & DMG_EXPLOSION) || (!inf && !src) || (inf == src)) { newdmg = dmg; console.printf("Skipped"); return; }
        double ang;
        if (inf) {
            // It's a projectile or puff.
            // if (inf is "BulletPuff") {
                // We might need custom logic here for handling hitscans.
                // I'm not sure whether bulletpuffs are spawned facing any particular angle.
            // }
            ang = absangle(inf.angle,owner.angleto(inf));
        } else if (src) {
            // It's a melee attack.
            ang = absangle(src.angle,owner.angleto(src));
        }
        double clang = clamp(ang,GLANCE,DIRECT); // 0 means head-on collision, 90 or more means the projectile has either struck the very edge or is behind the target
        double mult = LOWDMG + ((HIDMG - LOWDMG)/(DIRECT-GLANCE)) * (clang-GLANCE);
        newdmg = ceil(dmg * mult);
        console.printf("%s: Damage from %s was %d (%0.1f = X%0.1f)",owner.GetTag(),inf.GetTag(),newdmg,ang,mult);
    }
}

class GlanceHandler : EventHandler {
    override void WorldThingSpawned(WorldEvent e) {
        if (e.Thing.bISMONSTER || e.Thing.bSHOOTABLE || e.Thing is "PlayerPawn") {
            e.Thing.GiveInventory("GlanceBrain",1);
        }
    }
}