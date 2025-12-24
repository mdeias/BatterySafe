using Toybox.Graphics;
using State;
using FontManager;
using Palette;

class FooterRenderer {

    var _fontMid;
    var _fontDash;
    var _fontPipe;

    const DASH_TEXT = "--------------------";
    const BATT_LABEL = "Batt";
    const PIPE_TEXT = "|";

    // Cached geometry
    var _w;
    var _cx;

    var _clearY;
    var _clearH;

    var _dashY;
    var _dashTextY;

    var _battY;
    var _battLX;
    var _battRX;

    var _pipeY;
    
    var _lastScale;

    var _staticDrawn;


    function initialize() {
        _fontMid  = null;
        _fontDash = null;
        _fontPipe = null;

        _w = 0;
        _cx = 0;

        _clearY = 0;
        _clearH = 0;

        _dashY = 0;
        _dashTextY = 0;

        _battY = 0;
        _battLX = 0;
        _battRX = 0;

        _pipeY = 0;

        _lastScale = null;

        _staticDrawn = false;
    }

    function layout(dc as Graphics.Dc, s) {

        _fontMid  = FontManager.robotoBold(34.0 * s);
        _fontDash = FontManager.robotoBold(42.0 * s);
        _fontPipe = FontManager.robotoBold(40.0 * s);

        _w  = dc.getWidth();
        _cx = _w / 2.0;

        // area pulizia footer (la tua)
        _clearY = 310.0 * s;
        _clearH = 80.0 * s;

        // dash
        _dashY     = 292.0 * s;
        _dashTextY = _dashY + 14.0 * s;

        // battery row
        _battY  = _dashY + 42.0 * s;
        _battLX = _cx - 8.0 * s;
        _battRX = _cx + 8.0 * s;

        // pipe
        _pipeY = _battY - 4.0 * s;

        _staticDrawn = false; 

    }

    function invalidateStatic() {
        _staticDrawn = false;
    }


    function draw(dc as Graphics.Dc, state as State, s) {

        if (_lastScale == null || _lastScale != s) {
            layout(dc, s);
            _lastScale = s;
        }
    
        // -----------------------------------------
        // STATIC PART (disegnata UNA sola volta)
        // -----------------------------------------
        if (!_staticDrawn) {
        
            // pulizia completa footer SOLO la prima volta
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.fillRectangle(0, _clearY, _w, _clearH);
    
            // DASH + LABEL
            dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);
    
            // DASH LINE
            dc.drawText(
                _cx,
                _dashTextY,
                _fontDash,
                DASH_TEXT,
                Graphics.TEXT_JUSTIFY_CENTER
            );
    
            // "Batt"
            dc.drawText(
                _battLX,
                _battY,
                _fontMid,
                BATT_LABEL,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
    
            // PIPE centrale
            dc.setColor(Palette.ACCENT, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                _cx,
                _pipeY,
                _fontPipe,
                PIPE_TEXT,
                Graphics.TEXT_JUSTIFY_CENTER
            );
    
            _staticDrawn = true;
        }
    
        // -----------------------------------------
        // DYNAMIC PART (SOLO valore batteria)
        // -----------------------------------------
    
        // pulizia MICRO solo dove cambia il numero
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(
            _cx + 8.0 * s,
            _battY + (4.0 * s),
            (_w - _cx),
            (24.0 * s)
        );
    
        // valore batteria
        dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _battRX,
            _battY,
            _fontMid,
            state.devBatteryStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }



}
