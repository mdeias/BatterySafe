using Toybox.Graphics;
using State;
using FontManager;

class TopCenterRenderer {

    var _fontTime;
    var _fontTop;
    var _fontMid;
    var _fontPip;

    const DASH_TEXT = "--------------";
    const PIPE_TEXT = "|";

    // Cached geometry
    var _w;
    var _cx;

    var _clearY;
    var _clearH;

    var _timeY;
    var _timeX;

    var _touchY;
    var _dashY;
    var _bbY;

    var _leftX;

    var _pipeX;
    var _pipeY;

    function initialize() {
        _fontTime = null;
        _fontTop  = null;
        _fontMid  = null;
        _fontPip  = null;

        _w = 0;
        _cx = 0;

        _clearY = 0;
        _clearH = 0;

        _timeY = 0;
        _timeX = 0;

        _touchY = 0;
        _dashY  = 0;
        _bbY    = 0;

        _leftX = 0;

        _pipeX = 0;
        _pipeY = 0;
    }

    function layout(dc as Graphics.Dc, s) {

        _fontTime = FontManager.robotoBold(140.0 * s);
        _fontTop  = FontManager.robotoBold(26.0  * s);
        _fontMid  = FontManager.robotoBold(30.0  * s);
        _fontPip  = FontManager.robotoBold(110.0 * s);

        _w  = dc.getWidth();
        _cx = _w / 2.0;

        // area pulizia (la tua 120..240)
        _clearY = 120.0 * s;
        _clearH = 95.0 * s;

        // base positions (identiche al tuo)
        _timeY = 100.0 * s;
        _timeX = _cx + 50.0 * s;

        _leftX  = _cx + 62.0 * s;

        _touchY = _timeY + 31.0 * s;
        _dashY  = _timeY + 56.0 * s;
        _bbY    = _timeY + 78.0 * s;

        _pipeX = _w - 30.0 * s;
        _pipeY = _timeY + 18.0 * s;
    }

    function draw(dc as Graphics.Dc, state as State, s) {

        if (_fontTime == null) {
            layout(dc, s);
        }

        // -----------------------------------------
        // PARTIAL REDRAW: pulisci SOLO area TopCenter
        // -----------------------------------------
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, _clearY, _w, _clearH);

        // Stringhe da cache (in State le metti già non-null, ma safe comunque)
        var timeStr = state.timeStr;

        var touchText = state.touchStr;

        var bbText = state.bodyBatteryStr;

        // Tutto verde (ora + touch + dash + bb)
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        // ORA
        dc.drawText(
            _timeX,
            _timeY,
            _fontTime,
            timeStr,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // TOUCH
        dc.drawText(
            _leftX,
            _touchY,
            _fontMid,
            touchText,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // DASH
        dc.drawText(
            _leftX,
            _dashY,
            _fontMid,
            DASH_TEXT,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // BB
        dc.drawText(
            _leftX,
            _bbY,
            _fontMid,
            bbText,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // PIPE arancione
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _pipeX,
            _pipeY,
            _fontPip,
            PIPE_TEXT,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }
}
