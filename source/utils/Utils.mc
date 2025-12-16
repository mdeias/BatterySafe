using Toybox.Time;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

module RecoveryUtils {


    // Mappa day_of_week → id risorsa
    const WEEKDAY_STRINGS = [
        Rez.Strings.weekday_sun, // 0
        Rez.Strings.weekday_mon, // 1
        Rez.Strings.weekday_tue, // 2
        Rez.Strings.weekday_wed, // 3
        Rez.Strings.weekday_thu, // 4
        Rez.Strings.weekday_fri, // 5
        Rez.Strings.weekday_sat  // 6
    ];

    function getLocalizedWeekdayShort(dinfo) {
        var dow = dinfo.day_of_week; // 1..7

        if (dow < 1 || dow > 7) {
            dow = 1; // fallback a Sunday
        }

        var idx = dow - 1; // 1..7 → 0..6

        return WatchUi.loadResource(WEEKDAY_STRINGS[idx]);
    }


    // Es: "LUN 16" / "MON 16" automaticamente nella lingua del device
    function formatDate(dinfo)  {
        var dayName = getLocalizedWeekdayShort(dinfo);
        var dayNum  = dinfo.day.format("%d");
        return dayName + " " + dayNum;
    }

    // -------- TIME --------

    // Formatta HH:MM
    function formatTime(t) {
        var hh = t.hour;
        var mm = t.min;
        return pad2(hh) + ":" + pad2(mm);
    }

    function pad2(n) {
        return (n < 10) ? "0" + n : n + "";
    }

    // -------- SCREEN METRICS --------

    function getScreenMetrics(dc as Graphics.Dc) {
        var w      = dc.getWidth();
        var h      = dc.getHeight();
        var cx     = w / 2.0;
        var cy     = h / 2.0;
        var radius = (w < h ? w : h) / 2.0;

        return {
            :w      => w,
            :h      => h,
            :cx     => cx,
            :cy     => cy,
            :radius => radius
        };
    }

}
