using Toybox.Lang;

class State {

    // ----------------------------
    // Fallback constants (NO-NULL contract)
    // ----------------------------
    const TIME_FALLBACK   = "--:--";
    const DATE_FALLBACK   = "--";
    const STEPS_FALLBACK  = "ST: -- -> --%";
    const BATT_FALLBACK   = "--";
    const BB_FALLBACK     = "BB: --";
    const TOUCH_FALLBACK  = "Touch: --";

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
    var dateStr;         // MAI null
    var weekdayIndex;    // 0..6 (MAI null)

    // ----------------------------
    // Time cache (gestita in View)
    // ----------------------------
    var lastMinuteKey;   // hour*60 + min
    var timeStr;         // MAI null

    // ----------------------------
    // Values (numerici) - possono restare null
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
    // String cache (pronte per draw) - MAI null
    // ----------------------------
    var stepsLineStr;
    var devBatteryStr;
    var bodyBatteryStr;
    var touchStr;

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
        dateStr       = DATE_FALLBACK;
        weekdayIndex  = 0;

        lastMinuteKey = -1;
        timeStr       = TIME_FALLBACK;

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

        // string cache default (NO-NULL)
        stepsLineStr    = STEPS_FALLBACK;
        devBatteryStr   = BATT_FALLBACK;
        bodyBatteryStr  = BB_FALLBACK;
        touchStr        = TOUCH_FALLBACK;

        // primo draw completo
        dirtyHeader  = true;
        dirtyTop     = true;
        dirtyMid     = true;
        dirtyFooter  = true;
        needsFullRedraw = true;
    }

    // (opzionale) helper comodo se ti serve un numero "safe"
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
