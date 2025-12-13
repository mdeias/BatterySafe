using Toybox.Lang;

class State {

    // ----------------------------
    // Timestamp (ms)
    // ----------------------------
    var lastStepsTs;
    var lastBatteryTs;
    var lastBodyBatteryTs;

    // ----------------------------
    // Date cache
    // ----------------------------
    var lastDateKey;     // es: 20251213
    var dateStr;         // "13-12-2025"
    var weekdayIndex;    // 0..6 (Mo..Su)

    // ----------------------------
    // Time cache (gestita in View)
    // ----------------------------
    var lastMinuteKey;   // hour*60 + min
    var timeStr;         // "12:34"

    // ----------------------------
    // Values (numerici)
    // ----------------------------
    var devBattery;
    var hasRealDevBattery;

    var isTouchScreen;
    var hasRealIsTouchScreen;

    var steps;
    var stepGoal;
    var stepsPercent;
    var hasRealSteps;

    var bodyBattery;
    var hasRealBodyBattery;

    // ----------------------------
    // String cache (pronte per draw)
    // ----------------------------
    var stepsLineStr;      // "ST: 1234 -> 56%"
    var devBatteryStr;     // "85%"
    var bodyBatteryStr;    // "BB: 65"
    var touchStr;          // "Touch: ✓" / "Touch: ×" / "Touch: --"

    // ----------------------------
    // Dirty flags
    // ----------------------------
    var dirtyHeader;
    var dirtyTop;
    var dirtyMid;
    var dirtyFooter;

    // Full redraw al primo frame
    var needsFullRedraw;

    function initialize() {

        lastStepsTs       = 0;
        lastBatteryTs     = 0;
        lastBodyBatteryTs = 0;

        lastDateKey   = 0;
        dateStr       = "--";
        weekdayIndex  = 0;

        lastMinuteKey = -1;
        timeStr       = "--:--";

        devBattery        = null;
        hasRealDevBattery = false;

        isTouchScreen        = null;
        hasRealIsTouchScreen = false;

        steps        = null;
        stepGoal     = null;
        stepsPercent = null;
        hasRealSteps = false;

        bodyBattery        = null;
        hasRealBodyBattery = false;

        // string cache default
        stepsLineStr    = "ST: -- -> --%";
        devBatteryStr   = "--";
        bodyBatteryStr  = "BB: --";
        touchStr        = "Touch: --";

        // forza primo draw completo
        dirtyHeader  = true;
        dirtyTop     = true;
        dirtyMid     = true;
        dirtyFooter  = true;
        needsFullRedraw = true;
    }

    function safeNumber(v) {
        if (v == null) { return null; }
        if (v instanceof Lang.Number) { return v; }
        if (v has :toNumber) {
            try { return v.toNumber(); } catch(e) {}
        }
        return null;
    }

    function clearDirty() {
        dirtyHeader = false;
        dirtyTop    = false;
        dirtyMid    = false;
        dirtyFooter = false;
    }
}
