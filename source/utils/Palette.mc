using Toybox.Application;
using Toybox.Graphics;

module Palette {

    // colori “attivi”
    var PRIMARY = Graphics.COLOR_GREEN;
    var ACCENT  = Graphics.COLOR_ORANGE;

    function load() {
        var app = Application.getApp();

        var p = app.getProperty("primaryColor");
        var a = app.getProperty("accentColor");

        PRIMARY = mapIndexToColor(p);
        ACCENT  = mapIndexToColor(a);
    }

    function mapIndexToColor(v) {
        if (v == null) { return Graphics.COLOR_GREEN; }

        var idx;
        try {
            idx = v.toNumber();
        } catch(e) {
            idx = 0;
        }

        if (idx == 1) { return Graphics.COLOR_BLUE; }
        if (idx == 2) { return Graphics.COLOR_RED; }
        if (idx == 3) { return Graphics.COLOR_ORANGE; }
        if (idx == 4) { return Graphics.COLOR_YELLOW; }
        return Graphics.COLOR_GREEN;
    }
}
