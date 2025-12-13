using Toybox.Graphics;
using State;
using FontManager;

class HeaderRenderer {

    var _fontTop;
    var _fontTagline;

    function initialize() {
        _fontTop     = null;
        _fontTagline = null;
    }

    function layout(dc as Graphics.Dc, s) {
        _fontTop     = FontManager.robotoBold(26.0 * s);
        _fontTagline = FontManager.robotoBold(30.0 * s);
    }

    function draw(dc as Graphics.Dc, state as State, s) {

        if (_fontTop == null) {
            layout(dc, s);
        }

        var w  = dc.getWidth();
        var cx = w / 2.0;

        drawTopMarker(dc, s);

        // RIGA ST: steps -> %
        var topY = 64.0 * s;

        var stStepsText;
        var stPctText;

        if (state.hasRealSteps && state.steps != null && state.stepsPercent != null) {
            stStepsText = "Steps: " + state.steps.format("%d");
            stPctText   = state.stepsPercent.format("%d") + "%";
        } else {
            stStepsText = "Steps: --";
            stPctText   = "--%";
        }

        var text = stStepsText + "  ->  " + stPctText;

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            cx,
            topY,
            _fontTop,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // TAGLINE
        var taglineY = 92.0 * s;
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            taglineY,
            _fontTagline,
            "Battery Life Optimized",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // SIDE MARKERS "--|"
        var markerTextDx = "--|";
        var markerTextSx = "|--";
        var markerY    = taglineY;  // centrato verticalmente
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        // sinistra
        dc.drawText(
            30.0 * s,          // X sinistra
            markerY,
            _fontTop,          // o _fontTagline se vuoi più grande
            markerTextSx,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // destra
        dc.drawText(
            w - 30.0 * s,      // X destra (margine)
            markerY,
            _fontTop,
            markerTextDx,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

    }

        function drawTopMarker(dc as Graphics.Dc, scale) {

        var w = dc.getWidth();
        var s = scale;
        var cx = w / 2.0;

        var tri = 10.0 * s;
        var cy = 38.0 * s;

        var p1 = [ cx, cy + tri ];
        var p2 = [ cx - tri, cy - tri ];
        var p3 = [ cx + tri, cy - tri ];

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([ p1, p2, p3 ]);
    }
    
}
