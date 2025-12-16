using Toybox.Graphics;
using State;
using FontManager;

class HeaderRenderer {

    var _fontTop;
    var _fontTagline;

    const TAGLINE        = "Battery Life Optimized";
    const MARKER_LEFT    = "|--";
    const MARKER_RIGHT   = "--|";
    const HEADER_FALLBACK = "Last: --";

    // Cached geometry
    var _w;
    var _cx;

    var _clearH;

    var _topY;
    var _taglineY;
    var _markerY;

    var _markerLeftX;
    var _markerRightX;

    // Triangle cached basics
    var _tri;
    var _triCy;

    var _lastScale;

    // NEW
    var _staticDrawn;

    function initialize() {
        _fontTop     = null;
        _fontTagline = null;

        _w = 0;
        _cx = 0;

        _clearH = 0;

        _topY = 0;
        _taglineY = 0;
        _markerY = 0;

        _markerLeftX = 0;
        _markerRightX = 0;

        _tri = 0;
        _triCy = 0;

        _lastScale = null;

        _staticDrawn = false;
    }

    function layout(dc as Graphics.Dc, s) {

        _fontTop     = FontManager.robotoBold(26.0 * s);
        _fontTagline = FontManager.robotoBold(30.0 * s);

        _w  = dc.getWidth();
        _cx = _w / 2.0;

        // header clear
        _clearH = 120.0 * s;

        // text positions
        _topY     = 64.0 * s;
        _taglineY = 92.0 * s;
        _markerY  = _taglineY;

        // marker x
        _markerLeftX  = 30.0 * s;
        _markerRightX = _w - 30.0 * s;

        // triangle
        _tri   = 11.0 * s;
        _triCy = 38.0 * s;

        // NEW: se cambia scale/layout, ridisegna static
        _staticDrawn = false;
    }

    // NEW: utile quando in futuro cambi palette/settings
    function invalidateStatic() {
        _staticDrawn = false;
    }

    // NEW: static part (una sola volta)
    function drawStatic(dc as Graphics.Dc, s) {

        // pulizia completa header UNA volta
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, _w, _clearH);

        // triangolo pieno
        drawTopMarker(dc);

        // markers verdi
        dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            _markerLeftX,
            _markerY,
            _fontTop,
            MARKER_LEFT,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            _markerRightX,
            _markerY,
            _fontTop,
            MARKER_RIGHT,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // tagline arancione
        dc.setColor(Palette.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _cx,
            _taglineY,
            _fontTagline,
            TAGLINE,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        _staticDrawn = true;
    }

    function draw(dc as Graphics.Dc, state as State, s) {

        if (_lastScale == null || _lastScale != s) {
            layout(dc, s);
            _lastScale = s;
        }

        // 1) static (solo una volta)
        if (!_staticDrawn) {
            drawStatic(dc, s);
        }

        // 2) dynamic: SOLO riga steps
        // pulizia piccola sulla zona della riga steps (con padding conservativo)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(
            0,
            _topY - (8.0 * s),
            _w,
            (35.0 * s)
        );

        var text = state.headerStr;
        if (text == null) { text = HEADER_FALLBACK; }

        dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _cx,
            _topY,
            _fontTop,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawTopMarker(dc as Graphics.Dc) {

        var p1 = [ _cx,        _triCy + _tri ];
        var p2 = [ _cx - _tri, _triCy - _tri ];
        var p3 = [ _cx + _tri, _triCy - _tri ];

        dc.setColor(Palette.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([ p1, p2, p3 ]);
    }

}
