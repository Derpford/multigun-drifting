class DriftHud : DoomStatusBar {
    // Mainly here to draw the sway.

    HUDFont mConFont;

    override void Init() {
        Super.Init();
        mConFont = HUDFont.Create("CONFONT");
    }

    override void Draw(int state, double ticfrac) {
        super.Draw(state,ticfrac);
        DriftPlayer plr = DriftPlayer(CPlayer.mo);
        double fac = 1;
        let wep = DriftWeapon(CPlayer.readyweapon);
        if (wep) {
            fac = wep.swayfactor;
        }

        double sway = plr.sway * 5 * fac;
        double healthpercent = double(plr.health) / double (plr.GetMaxHealth());
		// "Enhanced" crosshair health (blue-green-yellow-red)
        // Borrowed from gzdoom's own code.
		int health = clamp(plr.health, 0, 200);
		float rr, gg, bb;

		float saturation = health < 150 ? 1.f : 1.f - (health - 150) / 100.f;
        rr = clamp(1.0 - healthpercent,0,1);
        gg = clamp(healthpercent,0,1);
        bb = clamp(healthpercent - 1.0,0,1);

		int red = int(rr * 255);
		int green = int(gg * 255);
		int blue = int(bb * 255);

		// int color = (red << 16) | (green << 8) | blue;
        Color col = Color(255,red,green,blue);
        DrawImage("XHAIRS2",(sway,0),DI_SCREEN_CENTER|DI_ITEM_CENTER,style:STYLE_Shaded,col: col);
        
        // rangefinder
        double rangefind = plr.rangefind;
        DrawString(mConFont,FormatNumber(rangefind,4,format:FNF_FILLZEROS),(0,16),DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER);

        // speedometer
        double spd = plr.vel.length();
        DrawString(mConFont,String.Format("%0.1f",spd),(0,32),DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER);
    }
}