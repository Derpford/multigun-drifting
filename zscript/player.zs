class DriftPlayer : DoomPlayer {
    // DOOMGUY DORIFTO
    mixin DampedSpring;

    const WALK = 12.0; // Anything below this is considered walking!
    const DT = 1./35.;

    double storedspd; // Stores the speed from our drift.
    double momentum; // Stores the bonus speed from drifting longer. Caps at around 15.
    Vector2 drift; // Which direction are we moving in?
    double driftangle; // Which direction is the drift facing toward? Approaches current angle.
    double sway; // Where the crosshair is swaying.
    double swayamp; // How far the crosshair sways.
    double swayampdelta; // How is the sway changing?

    double rangefind; // rangefinder value

    Default {
        Player.StartItem "UMP45";
        Player.StartItem "PlasmaPistol";
        Player.StartItem "Capacitor",20;
        Player.StartItem "Clip",50;
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        storedspd = -1; // No stored speed at the start!
    }

    override vector2 BobWeapon(double frac) {
        double fac = 1;
        double flip = 0;
        let w = DriftWeapon(player.readyweapon);
        if (w) {
            fac = w.swayfactor;
            flip = w.mflip;
        }
        double xpart = sway * 1.5 * fac;
        double ypart = flip + (abs(sway * 0.5) * fac);
        return (xpart,ypart);
    }

    override void Tick() {
        Super.Tick();
        // Do the rangefinder.
        double rfzoffs = height * 0.5 - floorclip + AttackZOffset * player.crouchFactor;
        FLineTraceData d;
        LineTrace(angle,9999,pitch,0,rfzoffs,data:d);
        rangefind = (pos - d.HitLocation).length();

        // First things first, check if we're crouching.
        int btns = GetPlayerInput(INPUT_BUTTONS);
        double side = GetPlayerInput(INPUT_SIDEMOVE);
        double forward = GetPlayerInput(INPUT_FORWARDMOVE);
        double inputangle = angle;
        vector2 inputs = (forward,-side).unit();
        // For drifting: If there's no movement going on at *all*, simply go forward.
        if (side == 0 && forward == 0 || inputs.length() <= 0 || inputs != inputs) {
            // Don't bother calculating angle.
        } else {
            inputangle += VectorAngle(inputs.x,inputs.y);
        }
        
        if (btns & BT_CROUCH) {
            // Engage dorifto.
            if (storedspd < 0) {
                storedspd = vel.length();
                drift = inputs.unit() == inputs.unit() ? inputs.unit() * vel.length() : (1,0) * vel.length();
                driftangle = angle;
            } else { // On everything after the first tick of drift...
                if (player.onground) {
                    double len = drift.length() == drift.length() ? drift.length() : 1.0;
                    double turn = 1.0 + abs(GetPlayerInput(INPUT_YAW) / 32767.);
                    double mod = DT * turn * 0.4 * len;
                    driftangle += DeltaAngle(driftangle,angle) * 1.5 * DT;
                    if (vel.xy.length() > 10) {
                        vel.xy = vel.xy.unit() * ( 10 - vel.xy.length() ) * 0.9;
                    }
                    drift = drift.unit() * max(7.0,len - mod); // Take a percentage from our drift.
                    if (len > 0) {
                        vel.xy = RotateVector(drift,driftangle); // set our velocity to the current drift amount.
                    }
                    momentum += mod * 1.5; // Store that percentage as bonus momentum.
                }
            }
        } else if (storedspd > 0 && drift == drift && inputangle == inputangle && drift.length() > 0) {
            // We've uncrouched. Release the speed.
            console.printf("Released speed: %0.1f, momentum: %0.1f",storedspd, momentum);
            console.printf("Final drift length: %0.1f",drift.length());

            if (momentum != momentum) {
                momentum = 0; //Oops, math ate your momentum.
            }
            VelFromAngle(storedspd+momentum,inputangle);
            momentum = 0;
            storedspd = -1;
            drift = (0,0);
        }

        // Handle sway after movement.
        double l = max(0.1, vel.length());
        double swayval = l * (l / WALK);
        double swayspeed = (player.readyweapon is "DriftWeapon") ? DriftWeapon(player.readyweapon).swayspeed : 1.0;
        swayampdelta = damp(swayamp,swayampdelta,vel.length() / WALK,0);
        swayamp += swayampdelta;
        sway = sin(GetAge() * 10 * swayspeed) * 10 * swayamp;
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
