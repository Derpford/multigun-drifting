class DriftHud : DoomStatusBar {
    // Mainly here to draw the sway.

    override void Draw(int state, double ticfrac) {
        super.Draw(state,ticfrac);
        double fac = 1;
        let wep = DriftWeapon(CPlayer.readyweapon);
        if (wep) {
            fac = wep.swayfactor;
        }
        double sway = DriftPlayer(CPlayer.mo).sway * 5 * fac;
        DrawImage("XHAIRS1",(sway,0),DI_SCREEN_CENTER|DI_ITEM_CENTER,style:STYLE_Shaded);
    }
}