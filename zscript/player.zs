class DriftPlayer : DoomPlayer {
    // DOOMGUY DORIFTO

    const WALK = 12.0; // Anything below this is considered walking!
    const DT = 1./35.;

    double storedspd; // Stores the speed from our drift.
    double momentum; // Stores the bonus speed from drifting longer. Caps at around 15.
    Vector2 drift; // Which direction are we moving in?
    double driftangle; // Which direction is the drift facing toward? Approaches current angle.
    double sway; // Where the crosshair is swaying.
    double swayamp; // How far the crosshair sways.

    Default {
        Player.StartItem "TestGun";
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        storedspd = -1; // No stored speed at the start!
    }

    override void Tick() {
        Super.Tick();
        // First things first, check if we're crouching.
        int btns = GetPlayerInput(INPUT_BUTTONS);
        double side = GetPlayerInput(INPUT_SIDEMOVE);
        double forward = GetPlayerInput(INPUT_FORWARDMOVE);
        double inputangle = angle;
        vector2 inputs = (forward,side).unit();
        // For drifting: If there's no movement going on at *all*, simply go forward.
        if (side == 0 && forward == 0) {
            // Don't bother calculating angle.
        } else {
            inputangle += atan2(-inputs.y,inputs.x);
        }
        
        if (btns & BT_CROUCH) {
            // Engage dorifto.
            if (storedspd < 0) {
                storedspd = vel.length();
                drift = RotateVector(vel.xy,-angle); // Store drift relative to facing.
                driftangle = angle;
            } else { // On everything after the first tick of drift...
                if (player.onground) {
                    double turn = 1.0 + abs(GetPlayerInput(INPUT_YAW) / 32767.);
                    double mod = DT * turn * 0.4 * drift.length();
                    driftangle += DeltaAngle(driftangle,angle) * 0.2;
                    if (vel.xy.length() > 10) {
                        vel.xy = vel.xy.unit() * ( 10 - vel.xy.length() ) * 0.9;
                    }
                    drift = drift.unit() * max(7.0,drift.length() - mod); // Take a percentage from our drift.
                    vel.xy = RotateVector(drift,driftangle); // set our velocity to the current drift amount.
                    momentum += mod * 1.5; // Store that percentage as bonus momentum.
                }
            }
        } else if (storedspd > 0) {
            // We've uncrouched. Release the speed.
            console.printf("Released speed: %0.1f, momentum: %0.1f",storedspd, momentum);
            console.printf("Final drift length: %0.1f",drift.length());

            VelFromAngle(storedspd+momentum,inputangle);
            momentum = 0;
            storedspd = -1;
            drift = (0,0);
        }

        // Handle sway after movement.
        double swayval = vel.length() < WALK ? vel.length() * 0.5 : vel.length();
        swayamp = swayamp + (swayval - swayamp) * min(1.0,vel.length() / WALK);
        sway = sin(GetAge() * 10) * swayamp;
    }

    override void CrouchMove(int direction)
	{
        // Almost the same, but with a different min height.
		let player = self.player;
		
		double defaultheight = FullHeight;
		double savedheight = Height;
		double crouchspeed = direction * CROUCHSPEED;
		double oldheight = player.viewheight;

		player.crouchdir = direction;
		player.crouchfactor += crouchspeed;

		// check whether the move is ok
		Height  = defaultheight * player.crouchfactor;
		if (!TryMove(Pos.XY, false, NULL))
		{
			Height = savedheight;
			if (direction > 0)
			{
				// doesn't fit
				player.crouchfactor -= crouchspeed;
				return;
			}
		}
		Height = savedheight;

		player.crouchfactor = clamp(player.crouchfactor, 0.7, 1.);
		player.viewheight = ViewHeight * player.crouchfactor;
		player.crouchviewdelta = player.viewheight - ViewHeight;

		// Check for eyes going above/below fake floor due to crouching motion.
		CheckFakeFloorTriggers(pos.Z + oldheight, true);
	}

    override void CheckJump()
	{
		let player = self.player;
		// [RH] check for jump
        // Mostly normal, but you can (crouch) bunnyhop.
        // Note that you *can* maintain speed during a drift with this, but you'll store no momentum this way...
		if (player.cmd.buttons & BT_JUMP)
		{
			if (waterlevel >= 2)
			{
				Vel.Z = 4 * Speed;
			}
			else if (bNoGravity)
			{
				Vel.Z = 3.;
			}
			else if (level.IsJumpingAllowed() && player.onground && player.jumpTics == 0)
			{
				double jumpvelz = JumpZ * 35 / TICRATE;
				double jumpfac = 0;

				// [BC] If the player has the high jump power, double his jump velocity.
				// (actually, pick the best factors from all active items.)
				for (let p = Inv; p != null; p = p.Inv)
				{
					let pp = PowerHighJump(p);
					if (pp)
					{
						double f = pp.Strength;
						if (f > jumpfac) jumpfac = f;
					}
				}
				if (jumpfac > 0) jumpvelz *= jumpfac;

                // If crouched, do a high jump.
                if (player.crouchoffset != 0) {
                    jumpvelz *= 2.0;
                }

				Vel.Z += jumpvelz;
				bOnMobj = false;
				// player.jumpTics = -1; // Bunnyhopping :D
				if (!(player.cheats & CF_PREDICTING)) A_StartSound("*jump", CHAN_BODY);
			}
		}
	}
}

class TestGun : Weapon {
    // Shoots simple projectiles.

    default {
        Weapon.SlotNumber 1;
    }

    action void Fire(Name proj) {
        double ang = 0;
        if (DriftPlayer(invoker.owner)) {
            let dp = DriftPlayer(invoker.owner);
            ang = -dp.sway;
        }

        A_FireProjectile(proj,angle:ang);
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
            PISG B 3 Fire("TestShot");
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