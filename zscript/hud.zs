class DriftHud : DoomStatusBar {
    // Mainly here to draw the sway.

    HUDFont mConFont;

    override void Init() {
        Super.Init();
        mConFont = HUDFont.Create("CONFONT");
    }

    // gently borrowed code
    void HsvToRgb(double h, double S, double V, out int r, out int g, out int b)
    {
    // ######################################################################
    // T. Nathan Mundhenk
    // mundhenk@usc.edu
    // C/C++ Macro HSV to RGB

    double H = h;
    while (H < 0) { H += 360; };
    while (H >= 360) { H -= 360; };
    double R2, G2, B2;
    if (V <= 0)
        { R2 = G2 = B2 = 0; }
    else if (S <= 0)
    {
        R2 = G2 = B2 = V;
    }
    else
    {
        double hf = H / 60.0;
        int i = Floor(hf);
        double f = hf - i;
        double pv = V * (1 - S);
        double qv = V * (1 - S * f);
        double tv = V * (1 - S * (1 - f));
        switch (i)
        {

        // Red is the dominant color

        case 0:
            R2= V;
            G2= tv;
            B2= pv;
            break;

        // Green is the dominant color

        case 1:
            R2= qv;
            G2= V;
            B2= pv;
            break;
        case 2:
            R2= pv;
            G2= V;
            B2= tv;
            break;

        // Blue is the dominant color

        case 3:
            R2= pv;
            G2= qv;
            B2= V;
            break;
        case 4:
            R2= tv;
            G2= pv;
            B2= V;
            break;

        // Red is the dominant color

        case 5:
            R2= V;
            G2= pv;
            B2= qv;
            break;

        // Just in case we overshoot on our math by a little, we put these here. Since its a switch it won't slow us down at all to put these here.

        case 6:
            R2= V;
            G2= tv;
            B2= pv;
            break;
        case -1:
            R2= V;
            G2= pv;
            B2= qv;
            break;

        // The color is not defined, we should throw an error.

        default:
            //LFATAL("i Value error in Pixel conversion, Value is %d", i);
            console.printf("Color error!");
            R2= G2= B2= V; // Just pretend its black/white
            break;
        }
    }
    r = Clamp((R2 * 255.0),0,255);
    g = Clamp((G2 * 255.0),0,255);
    b = Clamp((B2 * 255.0),0,255);
    }

    override void Draw(int state, double ticfrac) {
        super.Draw(state,ticfrac);
        DriftPlayer plr = DriftPlayer(CPlayer.mo);
        double fac = 1;

        double healthpercent = double(plr.health) / double (plr.GetMaxHealth());
		// "Enhanced" crosshair health (blue-green-yellow-red)
        // Borrowed from gzdoom's own code.
		int health = clamp(plr.health, 0, 200);
		// double rr, gg, bb;
        int red,green,blue;

		double saturation = health < 150 ? 1.f : 1.f - (health - 150) / 100.f;
        HsvToRgb(double(health) * 1.2,saturation,1,red,green,blue);
        Color col = Color(255,red,green,blue);
        double spacing = 12.0;
        Vector2 scl = (1.0,1.0);

        // Calculate weapon crosshair sway.
        let wep = DriftWeapon(CPlayer.readyweapon);
        if (wep) {
            fac = wep.swayfactor;
        }
        if (wep) {
            spacing += 1.1 * wep.mflip;
            scl += scl * (wep.mflip * 0.1);
        }
        double maxsway = 1.8 * 30 * fac;
        double sway = plr.sway * 30;
        if (wep) maxsway += 1.1 * wep.mflip;
        DrawImage("ARROWDN",(0,-spacing),DI_SCREEN_CENTER|DI_ITEM_CENTER,scale:scl,style:STYLE_Shaded,col: col);
        DrawImage("ARROWUP",(0,spacing),DI_SCREEN_CENTER|DI_ITEM_CENTER,scale:scl,style:STYLE_Shaded,col: col);
        DrawImage("RBRKT",(maxsway,0),DI_SCREEN_CENTER|DI_ITEM_CENTER,scale:scl,style:STYLE_Shaded,col: col);
        DrawImage("LBRKT",(-maxsway,0),DI_SCREEN_CENTER|DI_ITEM_CENTER,scale:scl,style:STYLE_Shaded,col: col);
        DrawImage("XHAIRS2",(sway,0),DI_SCREEN_CENTER|DI_ITEM_CENTER,style:STYLE_Shaded,col: col);
        
        // rangefinder
        double rangefind = plr.rangefind;
        DrawString(mConFont,FormatNumber(rangefind,4,format:FNF_FILLZEROS),(0,16),DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER);

        // speedometer
        double spd = plr.vel.length();
        DrawString(mConFont,String.Format("%0.1f",spd),(0,32),DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER);
    }
}