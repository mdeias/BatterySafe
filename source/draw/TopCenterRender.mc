using Toybox.Graphics;
using State;
using FontManager;

class TopCenterRenderer {

    var _fontTime;
    var _fontTop;
    var _fontMid;
    var _fontPip;
    const DASH_TEXT = "-------------";
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

    var _lastScale;

    // NEW
    var _staticDrawn;

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

        _lastScale = null;

        _staticDrawn = false;
    }

    function layout(dc as Graphics.Dc, s) {

        _fontTime = FontManager.robotoBold(140.0 * s);
        _fontTop  = FontManager.robotoBold(26.0  * s);
        _fontMid  = FontManager.robotoBold(28.0  * s);
        _fontPip  = FontManager.robotoBold(110.0 * s);

        _w  = dc.getWidth();
        _cx = _w / 2.0;

        // area pulizia (la tua)
        _clearY = 120.0 * s;
        _clearH = 95.0 * s;

        _timeY = 100.0 * s;
        _timeX = _cx + 60.0 * s;

        _leftX  = _cx + 62.0 * s;

        _touchY = _timeY + 32.0 * s;
        _dashY  = _timeY + 56.0 * s;
        _bbY    = _timeY + 78.0 * s;

        _pipeX = _w - 30.0 * s;
        _pipeY = _timeY + 18.0 * s;

        _staticDrawn = false;
    }

    function invalidateStatic() {
        _staticDrawn = false;
    }

    // ----------------------------
    // STATIC PART (una sola volta)
    // ----------------------------
    function drawStatic(dc as Graphics.Dc, s) {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(_leftX + 100 * s , _clearY, 30 * s, (90.0 * s));

        // PIPE
        dc.setColor(Palette.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _pipeX,
            _pipeY,
            _fontPip,
            PIPE_TEXT,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        _staticDrawn = true;
    }

    // ----------------------------
    // DRAW
    // ----------------------------
    function draw(dc as Graphics.Dc, state as State, s) {

        if (_lastScale == null || _lastScale != s) {
            layout(dc, s);
            _lastScale = s;
        }

        // 1) static
        if (!_staticDrawn) {
            drawStatic(dc, s);
        }

        // -----------------------------------------
        // DYNAMIC: ORA
        // -----------------------------------------
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(
            0,
            _timeY + (20.0 * s),
            _w - 35 * s,
            (90.0 * s)
        );

        dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _timeX,
            _timeY,
            _fontTime,
            state.timeStr,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);

        // TOUCH
        dc.drawText(
            _leftX,
            _touchY,
            _fontMid,
            state.touchStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // BB
        dc.drawText(
            _leftX,
            _bbY,
            _fontMid,
            state.bodyBatteryStr,
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
    }

    // ----------------------------
    // AOD: SOLO ORA (stessa posizione e dimensione del normale)
    // ----------------------------
    function drawAodTime(dc as Graphics.Dc, state as State, s, shiftX, shiftY) {

        // assicurati che layout sia pronto (usa lo stesso font/geo)
        if (_lastScale == null || _lastScale != s) {
            layout(dc, s);
            _lastScale = s;
        }

        // ora
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _timeX + shiftX,
            _timeY + shiftY,
            _fontTime,
            state.timeStr,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }


}
