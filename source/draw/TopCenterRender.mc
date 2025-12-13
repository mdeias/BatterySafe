using Toybox.Graphics;
using Toybox.System;
using State;
using FontManager;

class TopCenterRenderer {

    var _fontTime;
    var _fontTop;
    var _fontMid;
    var _fontPip;

    function initialize() {
        _fontTime = null;
        _fontTop  = null;
        _fontMid  = null;
        _fontPip  = null;
    }

    function layout(dc as Graphics.Dc, s) {
        _fontTime = FontManager.robotoBold(140.0 * s);
        _fontTop  = FontManager.robotoBold(26.0  * s);
        _fontMid  = FontManager.robotoBold(30.0  * s);
        _fontPip  = FontManager.robotoBold(110.0  * s);
    }

    function draw(dc as Graphics.Dc, state as State, s) {

        if (_fontTime == null) {
            layout(dc, s);
        }

        var w  = dc.getWidth();
        var cx = w / 2.0;

        // ORA
        var nowClock = System.getClockTime();
        var hour     = nowClock.hour;
        var minute   = nowClock.min;

        var timeStr = hour.format("%02d") + ":" + minute.format("%02d");

        // ORA (posizionamento come il tuo)
        var timeY = 110.0 * s;

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx + 50.0 * s,
            timeY,
            _fontTime,
            timeStr,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // TOUCH (a destra)
        var touchLabelY = timeY + 31.0 * s;

        var touchText;
        if (!state.hasRealIsTouchScreen || state.isTouchScreen == null) {
            touchText = "Touch: --";
        } else {
            touchText = state.isTouchScreen ? "Touch: ✓" : "Touch: x";
        }

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx + 62.0 * s,
            touchLabelY,
            _fontMid,
            touchText,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // LINEA "TRATTEGGIATA" come TEXT (ottimizzata)
        // (tieni le tue coordinate, puoi rifinire poi)
        var dashText = "--------------";
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx + 62.0 * s,
            (110.0 * s) + 56.0 * s,   // equivale al tuo dashY + 40*s senza variabili inutili
            _fontMid,
            dashText,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // BB (al posto della data)
        var bbY = timeY + 78.0 * s;

        var bbText;
        if (state.hasRealBodyBattery && state.bodyBattery != null) {
            bbText = "BodyB: " + state.bodyBattery.format("%d");
        } else {
            bbText = "BodyB: --";
        }

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx + 62.0 * s,
            bbY,
            _fontMid,
            bbText,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        var pipeY = timeY + 18.0 * s;
        dc.drawText(
            w - 30.0 * s,
            pipeY ,
            _fontPip,
            "|",
            Graphics.TEXT_JUSTIFY_LEFT
        );

    }
}
