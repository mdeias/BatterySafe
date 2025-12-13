using Toybox.Graphics;
using Toybox.Time;
using State;
using FontManager;

class MidCenterRenderer {

    var _fontMid;
    var _fontSmall;
    var _fontPip;

    function initialize() {
        _fontMid   = null;
        _fontSmall = null;
        _fontPip   = null;
    }

    function layout(dc as Graphics.Dc, s) {
        _fontMid   = FontManager.robotoBold(30.0 * s);
        _fontSmall = FontManager.robotoBold(22.0 * s);
        _fontPip   = FontManager.robotoBold(70.0 * s);
    }

    function draw(dc as Graphics.Dc, state as State, s) {

        if (_fontMid == null) {
            layout(dc, s);
        }

        var w  = dc.getWidth();
        var cx = w / 2.0;

        // ---- BARRE SETTIMANA: base Y fissa ----
        var barsY      = 268.0 * s;
        var barWidth   = 32.0 * s;
        var barHeight  = 16.0 * s;
        var barSpacing = 8.0 * s;

        var firstX = cx - (3 * (barWidth + barSpacing));

        // ---- Unica lettura data/weekday ----
        var dinfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dow = dinfo.day_of_week;
        var weekdayIndex;

        if (dow == 0) {
            // 0..6 con 0=Domenica
            weekdayIndex = (dow + 6) % 7;
        } else {
            // 1..7 con 1=Domenica
            weekdayIndex = (dow + 5) % 7;
        }

        // DATA centrata sopra le barre
        var dateStr = dinfo.day.format("%02d") + "-" +
                      dinfo.month.format("%02d") + "-" +
                      dinfo.year.format("%04d");

        var dateY = barsY - 48.0 * s;

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            dateY,
            _fontMid,
            dateStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // ---- Barre (tutte verdi) ----
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_GREEN);
        for (var i = 0; i < 7; i += 1) {
            var bx = firstX + i * (barWidth + barSpacing);
            dc.fillRectangle(bx, barsY, barWidth, barHeight);
        }

        // ---- CAP arancione sopra il giorno corrente (alto metà) ----
        // (gap piccolo per separazione visiva)
        var capH   = (barHeight / 2.0);
        var capGap = 2.0 * s;

        if (weekdayIndex != null) {
            var idx = weekdayIndex;
            // sicurezza: clamp 0..6
            if (idx < 0) { idx = 0; }
            if (idx > 6) { idx = 6; }

            var capX = firstX + idx * (barWidth + barSpacing);
            var capY = barsY - capH - capGap;

            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_ORANGE);
            dc.fillRectangle(capX, capY, barWidth, capH);
        }

        // ---- Label giorni ----
        var daysLabels = [ "Mo","Tu","We","Th","Fr","Sa","Su" ];
        var daysY      = barsY + 22.0 * s;

        for (var j = 0; j < 7; j += 1) {

            var tx = firstX + j * (barWidth + barSpacing) + barWidth/2;

            if (j == weekdayIndex) {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }

            dc.drawText(
                tx,
                daysY,
                _fontSmall,
                daysLabels[j],
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // "Day" (a sinistra della data)
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            firstX + 10.0 * s,
            dateY,
            _fontMid,
            "Day",
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // "|_" (struttura a sinistra barre)
        var structY = barsY + (barHeight / 2.0) + 2.0 * s;

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            firstX - 42.0 * s,
            structY - 57.0 * s,
            _fontPip,
            "|_",
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }
}
