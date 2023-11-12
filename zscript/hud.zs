class DriftHud : DoomStatusBar {
    // Mainly here to draw the sway.

    HUDFont mConFont;

    override void Init() {
        Super.Init();
        mConFont = HUDFont.Create("CONFONT");
    }

    override void Draw(int state, double ticfrac) {
        super.Draw(state,ticfrac);
        double fac = 1;
        let wep = DriftWeapon(CPlayer.readyweapon);
        if (wep) {
            fac = wep.swayfactor;
        }
        double sway = DriftPlayer(CPlayer.mo).sway * 5 * fac;
        DrawImage("XHAIRS1",(sway,0),DI_SCREEN_CENTER|DI_ITEM_CENTER,style:STYLE_Shaded);
        
        // rangefinder
        double rangefind = DriftPlayer(CPlayer.mo).rangefind;
        DrawString(mConFont,FormatNumber(rangefind,4,format:FNF_FILLZEROS),(0,16),DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER);
    }
}