class DriftHud : DoomStatusBar {
    // Mainly here to draw the sway.

    override void Draw(int state, double ticfrac) {
        super.Draw(state,ticfrac);

        double sway = DriftPlayer(CPlayer.mo).sway * 5;
        DrawImage("XHAIRS1",(sway,0),DI_SCREEN_CENTER|DI_ITEM_CENTER,style:STYLE_Shaded);
    }
}