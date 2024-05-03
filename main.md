# Multi-Gun Drifting
A tactical doom mod at full speed.

# Design Pillars
- The player should be able to move at full Doomguy speed whenever they feel like it. *This should be a meaningful decision to make*. The tactical-ness comes from having to choose when to move, not from being forced to commit to it.
- The game should feel like it's barely controllable, but controllable.
- Weapons should generally take out vanilla zombies and imps in one shot.

# Core Mechanics

## Aiming
Your point of aim will sweep left and right as you move, based on how fast you're moving. This means that *theoretically* you can put every shot on target while moving at full speed. However, 9 times out of 10, you'll want to slow down to shoot. Below walking speed, your point of aim barely moves, and coming to a stop snaps the aim point to the center of the screen. Aim sway ramps up over about a second of running.

It should be viable to run past a horde and spray into it, but this isn't ideal because…

## Damage Modifiers
You deal more or less damage to targets based on how square the hit was. Damage ramps up to 2.0x if the shot lands exactly at the center of the target, and down to 0.5x if the shot lands right at the edge of the target (this is achieved by doing `absangle` on the projectile and the angle to what the projectile hit–-0 means a perfect hit, 90 or more means a glancing blow). This applies to the player as well, so near-misses should feel a little less bullshit, while directly facetanking things will be extremely dangerous.

## Projectile Drift
All of your weapons fire projectiles. However, not all projectiles are created equal! Each projectile has a "drift factor" and "optimum range"; after the optimum range, the projectile will start deviating from its flight path, as eddies in the airstream (so he is, isn't he) mess with the projectile. This drift happens in the XY axis--the projectile *also* starts losing Z velocity at this point, though this will probably only matter at extreme ranges. In effect, spread gets much worse past the optimum range.

## Player Drift
You need to be able to stop on a dime to fire accurate shots, while keeping your doomguy momentum. How? Simple: *Doomguy dorifto*

Press and hold the crouch button while moving faster than walking speed, and you'll start drifting. This will:
1. Save your current movement speed,
2. cap your movement at walk-speed while you're on the ground, 
3. keep you moving in the direction you input last, 
4. gradually store momentum, reducing your movement a little further.

Upon releasing the crouch button, you'll unleash the stored speed plus the momentum in whatever direction you input, enabling super-fast cornering. In addition, since you slow to walk speed while drifting, you'll fire way more accurately! This can also give you a big burst of speed for a short distance. However, drifting slows you down--and it slows you down a *lot* if you hold it forever. There's a point at which you can't store any more momentum, and it's around the time you stop moving entirely.

# Weapons

TODO: Weapon descriptions.

# Armor

Instead of finding and discarding whole pieces of armor, you're actually finding armor plates for your plate carrier. There's still only two kinds of armor: green for kevlar-lined steel, and blue for ceramic.

You can carry up to two plates of each type. One plate of each type will be used at a time. All plates provide 50% save percent.

Steel (green) armor plates additionally absorb up to a flat 10 damage from each attack, which is great against glancing blows from hitscan attacks. Each one absorbs up to 200 points of damage before breaking.

Ceramic (blue) armor plates absorb up to 60 points of damage as flat absorption, and have a durability of 100. Due to absorbing so much flat damage, this doesn't last long, but it can save your life.

Having plates of both types at the same time absorbs a *lot* of damage and makes ceramic plates last a while longer.

Armor bonuses are replaced by Armor Repair Bonuses, which--instead of immediately adding their value--provide armor regen over time. Note that a sufficiently powerful attack can still break a plate outright, even if you have repair bonuses in your inventory.

Megaspheres give 200 units of Armor Repair Bonus instead of blue armor.
