using Toybox.Graphics;
using State;
using FontManager;

class FooterRenderer {

    var _fontMid;
    var _fontDash;     // font più piccolo per la riga "---"
    var _fontPipe;     // font grande per "|"

    function initialize() {
        _fontMid  = null;
        _fontDash = null;
        _fontPipe = null;
    }

    function layout(dc as Graphics.Dc, s) {
        _fontMid  = FontManager.robotoBold(34.0 * s);
        _fontDash = FontManager.robotoBold(42.0 * s);   // regola a gusto
        _fontPipe = FontManager.robotoBold(40.0 * s);   // grande per "|"
    }

    function draw(dc as Graphics.Dc, state as State, s) {

        if (_fontMid == null) {
            layout(dc, s);
        }

        var w  = dc.getWidth();
        var cx = w / 2.0;

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        // -------------------------------------------------
        //  DASH LINE come TEXT
        // -------------------------------------------------
        var dashY = 292.0 * s;

        // scegli tu il pattern (più lungo = più “pieno”)
        var dashText = "--------------------";

        // Mettila centrata e con margini uguali (semplice)
        dc.drawText(
            cx,
            dashY + 14.0 * s,
            _fontDash,
            dashText,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // -------------------------------------------------
        //  BATTERIA
        // -------------------------------------------------
        var battY = dashY + 42.0 * s;

        var battStr;
        if (state.hasRealDevBattery && state.devBattery != null) {
            battStr = state.devBattery.format("%d") + "%";
        } else {
            battStr = "--";
        }

        // "Batt"
        dc.drawText(
            cx - 8.0 * s,
            battY,
            _fontMid,
            "Batt",
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // valore
        dc.drawText(
            cx + 8.0 * s,
            battY,
            _fontMid,
            battStr,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // -------------------------------------------------
        //  SEPARATORE CENTRALE: scegli una delle due opzioni
        // -------------------------------------------------

        // (A) PIPE come testo grande "|"
        // Nota: posizionamento verticale: aggiusta +/-
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        var pipeY = battY - 4.0 * s;
        dc.drawText(
            cx,
            pipeY,
            _fontPipe,
            "|",
            Graphics.TEXT_JUSTIFY_CENTER
        );

    }
}
