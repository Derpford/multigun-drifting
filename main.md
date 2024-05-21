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

## Plasma Pistol
The UAC-20 Personal Plasma Weapon is a roughly pistol-sized self-charging energy weapon. Its power output isn't great compared to other plasma weaponry; however, its real benefit lies in logistics. Commonly issued to both security guards and commandos, the UAC-20 PPW has saved lives in both combat and long-term survival situations, while saving the UAC massive amounts of money on ammunition manufacturing.

The PPW's core components actually don't take up much space inside the device; this has led some users to perform aftermarket modifications, hooking up the self-charging capacitors in parallel to drive more current through the projection coils. This effectively creates a hyperburst-like effect, causing the PPW to fire multiple plasma bolts in an infinitesimal period of time. However, the power draw outscales the charge rate of the extra capacitors, making modified PPWs prone to running dry faster.

Press primary fire to fire the Plasma Pistol. Ammunition recharges automatically over time. Pick up additional Plasma Pistols to improve charge capacity and damage output.

## SMG
Supposedly, this PDW's design was based on an old classic, which the UAC bought all the rights to shortly after making a mint via their teleporter technology. The UAC MP-10 is chambered in the UAC's 10mm armor-piercing round--the same one used in their Squad Automatic Weapon--and thus brings a mixture of power and ease-of-use to the table, while easily accepting the most common ammunition in UAC facilities. A must-have for anyone operating in the ruins of the UAC's facilities.

Primary fire to fire. Short, controlled bursts are key.

## Sawn-Off Shotgun
There are a million of these, in various forms, made by various companies, modified by amateur gunsmiths across the solar system. Good luck finding any specific details.

Primary fire to fire the left barrel, alternate fire to fire the right barrel. You can fire both barrels basically at the same time. Press Reload to load fresh shells early. You can cancel out of the reload animation by switching weapons.

Note that the buckshot starts spreading almost instantly, but there's a "sweet spot" right in front of the barrels where the shot hasn't spread out--leading to better damage on a single target. This thing can gib most human-size enemies with ease.

## Pump Shotgun
The Benellus 12 has been manufactured as long as anybody can remember. Supposedly, Benellus himself has been alive for hundreds of years, but this is probably just someone in the marketing team who thinks he's clever. There can't really be a god of shotguns, right?

Primary fire to fire. It fires faster than you might expect, though you'll want to time the shots carefully if you're firing on the move. The longer barrel and tighter choke on this weapon makes it more accurate at longer ranges, while still packing a lot of stopping power in close quarters. This is your workhorse.

## Squad Automatic Weapon
The GAU-6 Squad Automatic Weapon--or as the UAC designates it, the UAC-30 Chaingun--is a lead-spitting beast. Boasting six barrels, synchronized to fire two at once, it has an effective rate of fire beyond almost anything else in production today while *also* avoiding overheating issues. Its recoil can be difficult to control, but the volume of fire you can put out with this thing makes up for it.

Primary fire to fire. Spread increases as you hold down the trigger, similar to the SMG. Chews through ammo and demons in equal measure.

## Rocket Launcher
The UAC developed a high-end man-portable antitank weapon shortly after the portal storms started hitting. While the UAC was being picked apart and sold to the highest bidder during the collapse of society, their laser-guided RPG prototype was quietly scooped up by the remnants of Earth's organized militaries, and once it saw full deployment, it had a dramatic effect on the war against the demons.

Primary fire to fire. The rocket will be lobbed out the front of the launcher; if it hits something before the rocket motor ignites, it'll fall to the ground and can be collected. Don't underestimate how much getting bonked in the face with a rocket hurts.

Once it ignites, it'll beeline for wherever the laser pointer is pointing. Note that the laser pointer is pointing wherever the rocket launcher is pointing, which means that if you're at a dead sprint, it might be pointing way off to the side.

The rocket launcher does a massive amount of splash damage, not to mention that it's more likely to land a direct hit on target due to the laser guidance. Rockets are powerful. Note that you can fire and guide many rockets at once.

## Pulse Rifle
An experimental prototype energy weapon using the UAC's ultradense energy storage tech. Unlike the Plasma Pistol, this thing can't self-charge--it's actually using an older version of the UAC's power tech. The pulse rifle program was scrapped when the teleporters took off, and was buried even deeper once the UAC figured out that they'd stumbled on free energy too. A shame; this thing hits really hard, and if they'd worked out the heat problems, it could have been the standard infantry rifle of the future.

Primary fire to fire. Holding down the trigger gradually heats the weapon up, causing it to fire more slowly. It'll cool off over time, whether it's in your hands, in your inventory, or on the ground. The more white steam particles are coming off of this thing, the hotter it is.

# Armor

Instead of finding and discarding whole pieces of armor, you're actually finding armor plates for your plate carrier. There's still only two kinds of armor: green for kevlar-lined steel, and blue for ceramic.

You can carry up to two plates of each type. One plate of each type will be used at a time.

Steel plates provide 40% damage resistance until they break, and can take a lot of punishment. Ceramic plates provide 60% damage resistance, but break significantly faster.

Plates lose durability according to the following process:
- First, roll a random number between zero and the absorbed damage. Add the 'recent damage' variable to this number.
- If that total is higher than the armor's "durability check" value (75 for green armor, 20 for blue armor)...
    - Take durability equal to 1/10th of the damage that was absorbed.
    - If durability drops to zero or less, remove one plate and reset durability to full. (Durability loss doesn't "roll over" to the next plate.)
- Otherwise...
    - Add the damage of the attack to the "recent damage" variable.
- The "recent damage" variable ticks down at a rate of 35/second, and basically ensures that you can't just stand in front of a chaingunner and not take any armor damage.

Having plates of both types at the same time absorbs a *lot* of damage and makes ceramic plates last a while longer.

Armor bonuses are replaced by Armor Repair Bonuses, which--instead of immediately adding their value--provide armor regen over time. Note that a sufficiently powerful attack can still break a plate outright, even if you have repair bonuses in your inventory.

Megaspheres give 200 units of Armor Repair Bonus instead of blue armor.
