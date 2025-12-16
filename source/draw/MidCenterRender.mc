using Toybox.Graphics;
using State;
using FontManager;

class MidCenterRenderer {

    var _fontMid;
    var _fontSmall;
    var _fontPip;

    const DAYS = [ "Mo","Tu","We","Th","Fr","Sa","Su" ];

    // ----------------------------
    // Cached geometry (layout)
    // ----------------------------
    var _w;
    var _cx;

    var _clearY;
    var _clearH;

    var _barsY;
    var _barW;
    var _barH;
    var _barSp;
    var _firstX;

    var _dateY;
    var _daysY;

    var _capH;
    var _capGap;

    var _dayLabelX;
    var _structX;
    var _structY;

    var _lastScale;

    // NEW
    var _staticDrawn;

    function initialize() {
        _fontMid   = null;
        _fontSmall = null;
        _fontPip   = null;

        _w = 0;
        _cx = 0;

        _clearY = 0;
        _clearH = 0;

        _barsY = 0;
        _barW  = 0;
        _barH  = 0;
        _barSp = 0;
        _firstX = 0;

        _dateY = 0;
        _daysY = 0;

        _capH = 0;
        _capGap = 0;

        _dayLabelX = 0;
        _structX = 0;
        _structY = 0;

        _lastScale = null;

        _staticDrawn = false;
    }

    function layout(dc as Graphics.Dc, s) {

        _fontMid   = FontManager.robotoBold(30.0 * s);
        _fontSmall = FontManager.robotoBold(22.0 * s);
        _fontPip   = FontManager.robotoBold(70.0 * s);

        _w  = dc.getWidth();
        _cx = _w / 2.0;

        // area pulizia (la tua)
        _clearY = (220.0 * s);
        _clearH = (100.0 * s);

        // barre
        _barsY = 268.0 * s;
        _barW  = 32.0 * s;
        _barH  = 16.0 * s;
        _barSp = 8.0 * s;

        _firstX = _cx - (3 * (_barW + _barSp));

        // date e labels
        _dateY = _barsY - 48.0 * s;
        _daysY = _barsY + 22.0 * s;

        // cap
        _capH   = (_barH / 2.0);
        _capGap = 2.0 * s;

        // "Day" e "|_"
        _dayLabelX = _firstX + 10.0 * s;

        _structY = _barsY + (_barH / 2.0) + 2.0 * s;
        _structX = _firstX - 42.0 * s;

        // NEW: se cambia scale/layout, ridisegna static
        _staticDrawn = false;
    }

    function invalidateStatic() {
        _staticDrawn = false;
    }

    // ----------------------------
    // STATIC PART (una sola volta)
    // ----------------------------
    function drawStatic(dc as Graphics.Dc, s) {

        // pulizia completa mid area UNA volta
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, _clearY, _w, _clearH);

        // ---- Barre verdi (sempre uguali) ----
        dc.setColor(Palette.PRIMARY, Palette.PRIMARY);
        for (var i = 0; i < 7; i += 1) {
            var bx = _firstX + i * (_barW + _barSp);
            dc.fillRectangle(bx, _barsY, _barW, _barH);
        }

        // "|_" (static)
        dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _structX,
            _structY - 57.0 * s, // mantengo il tuo offset originale
            _fontPip,
            "|_",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        _staticDrawn = true;
    }

    // ----------------------------
    // DRAW (static + dynamic)
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

        // ---- Date + weekday da STATE ----
        var weekdayIndex = state.weekdayIndex;
        if (weekdayIndex < 0) { weekdayIndex = 0; }
        if (weekdayIndex > 6) { weekdayIndex = 6; }

        var dateStr = state.dateStr;

        // 2) dynamic: pulizia SOLO area data+cap+highlight label
        // (non tocco le barre verdi base né le label bianche statiche)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(
            45 * s,
            _dateY - (3.0 * s),
            _w - 87.0 * s,
            (50.0 * s)
        );

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(
            75 * s,
            _dateY + (72.0 * s),
            _w - 117.0 * s,
            (20.0 * s)
        );

        // ridisegno data
        dc.setColor(Palette.PRIMARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _cx,
            _dateY,
            _fontMid,
            dateStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // ---- Label giorni bianche (base) ----
        // FIX: non disegnare in bianco il giorno corrente (evita overlay/fuzzy)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        for (var j = 0; j < 7; j += 1) {
        
            if (j == weekdayIndex) { 
                continue; 
            }
        
            var tx = _firstX + j * (_barW + _barSp) + (_barW / 2.0);
            dc.drawText(
                tx,
                _daysY,
                _fontSmall,
                DAYS[j],
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // CAP arancione sopra il giorno corrente
        var capX = _firstX + weekdayIndex * (_barW + _barSp);
        var capY = _barsY - _capH - _capGap;

        dc.setColor(Palette.ACCENT, Palette.ACCENT);
        dc.fillRectangle(capX, capY, _barW, _capH);

        // label giorno corrente in arancione sopra quella bianca
        var tx = capX + (_barW / 2.0);
        dc.setColor(Palette.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            tx,
            _daysY,
            _fontSmall,
            DAYS[weekdayIndex],
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // "Day" (ridisegnato perché la clear dinamica lo copre)
        dc.setColor(Palette.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _dayLabelX,
            _dateY,
            _fontMid,
            "Day",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    // ----------------------------
    // AOD: SOLO DATA (stessa posizione e dimensione del normale)
    // ----------------------------
    function drawAodDate(dc as Graphics.Dc, state as State, s, shiftX, shiftY) {

        if (_lastScale == null || _lastScale != s) {
            layout(dc, s);
            _lastScale = s;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _cx + shiftX,
            _dateY + shiftY,
            _fontMid,
            state.dateStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
