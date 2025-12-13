using Toybox.Graphics;
using State;
using FontManager;

class HeaderRenderer {

    var _fontTop;
    var _fontTagline;

    const TAGLINE      = "Battery Life Optimized";
    const MARKER_LEFT  = "|--";
    const MARKER_RIGHT = "--|";
    const STEPS_FALLBACK = "ST: -- -> --%";

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
        _tri   = 10.0 * s;
        _triCy = 38.0 * s;
    }

    function draw(dc as Graphics.Dc, state as State, s) {

        if (_fontTop == null) {
            layout(dc, s);
        }

        // -----------------------------------------
        // PARTIAL REDRAW: pulisci SOLO l'area header
        // -----------------------------------------
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, _w, _clearH);

        // triangolo pieno
        drawTopMarker(dc);

        // steps line (cache)
        var text = state.stepsLineStr;

        // verde: steps + markers
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            _cx,
            _topY,
            _fontTop,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // markers
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
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _cx,
            _taglineY,
            _fontTagline,
            TAGLINE,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawTopMarker(dc as Graphics.Dc) {

        var p1 = [ _cx,        _triCy + _tri ];
        var p2 = [ _cx - _tri, _triCy - _tri ];
        var p3 = [ _cx + _tri, _triCy - _tri ];

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([ p1, p2, p3 ]);
    }
}
