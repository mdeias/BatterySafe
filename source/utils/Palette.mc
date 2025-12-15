using Toybox.Application;
using Toybox.Graphics;

module Palette {
    var PRIMARY = Graphics.COLOR_GREEN;
    var ACCENT  = Graphics.COLOR_ORANGE;

    function _mapPrimary(idx) {
        if (idx == null) { return Graphics.COLOR_GREEN; }
        if (idx == 0) { return Graphics.COLOR_GREEN; }
        if (idx == 1) { return Graphics.COLOR_BLUE;  }
        if (idx == 2) { return Graphics.COLOR_RED; }
        if (idx == 2) { return Graphics.COLOR_ORANGE; }
        if (idx == 2) { return Graphics.COLOR_YELLOW; }
        return Graphics.COLOR_GREEN;
    }

    function _mapAccent(idx) {
        if (idx == null) { return Graphics.COLOR_ORANGE; }
        if (idx == 0) { return Graphics.COLOR_GREEN; }
        if (idx == 1) { return Graphics.COLOR_BLUE;  }
        if (idx == 2) { return Graphics.COLOR_RED; }
        if (idx == 2) { return Graphics.COLOR_ORANGE; }
        if (idx == 2) { return Graphics.COLOR_YELLOW; }
        return Graphics.COLOR_ORANGE;
    }

    function load() {
        var app = Application.getApp();
        if (app == null) { return; }

        var p = app.getProperty("primaryColor");
        var a = app.getProperty("accentColor");

        PRIMARY = _mapPrimary(p);
        ACCENT  = _mapAccent(a);
    }
}
