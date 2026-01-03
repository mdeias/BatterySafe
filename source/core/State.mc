using Toybox.Lang;

class State {

    // ----------------------------
    // Fallback (NO-NULL)
    // ----------------------------
    const TIME_FALLBACK   = "--:--";
    const DATE_FALLBACK   = "--";
    const BATT_FALLBACK   = "--";
    const HEADER_FALLBACK = "--";
    const TOP1_FALLBACK   = "--";
    const TOP2_FALLBACK   = "--";

    // ----------------------------
    // Time / Date cache
    // ----------------------------
    var lastMinuteKey;     // hour*60 + min
    var timeStr;           // MAI null

    var lastDateKey;       // yyyymmdd
    var dateStr;           // MAI null
    var weekdayIndex;      // 0..6

    // ----------------------------
    // Battery core
    // ----------------------------
    var lastBatteryTs;     // ms
    var devBattery;        // Number (può essere null)
    var devBatteryStr;     // MAI null ("85%"/"--")
    var hasRealDevBattery; // Bool
    var charging;          // Bool
    var lastChargingCheckTs;
    // ----------------------------
    // Battery tracking (trend / charge)
    // ----------------------------
    var lastBattSamplePct; // Number (può essere null)
    var lastBattSampleTs;  // ms
    var lastRatePerHour;   // Float (può essere null)  <-- NECESSARIA

    var chargeStartTs;     // ms (quando entra charging=true)
    var lastChargeEndTs;   // ms (quando esce charging=false)
    var lastChargeDurMs;   // ms (durata ultima sessione di carica)

    // Header refresh throttle
    var lastHeaderTs;      // ms

    // ----------------------------
    // Fixed lines (cache pronta) - MAI null
    // ----------------------------
    var headerStr;         // "Last: 3h 20m"
    var topLine1Str;       // "Δ -1.2%/h"

    // ----------------------------
    // Custom slot (al posto di Body Battery)
    // 0=TTE, 1=EFF, 2=CHG_SESSION
    // ----------------------------
    var topLine2Mode;      // Number (MAI null, default 1 se vuoi Eff)
    var topLine2Str;       // MAI null

    // (opzionale) cache interne (NO-NULL)
    var timeToEmptyStr;
    var effScoreStr;
    var chargeSessionStr;
    var lastChargeElapsedStr;

    // ----------------------------
    // Dirty flags
    // ----------------------------
    var dirtyHeader;
    var dirtyTime;      // solo ora (top time)
    var dirtyTopLines;  // line1 + line2 + dash
    var dirtyMid;
    var dirtyFooter;

    var needsFullRedraw;

    function initialize() {

        // time/date
        lastMinuteKey = -1;
        timeStr       = TIME_FALLBACK;

        lastDateKey   = 0;
        dateStr       = DATE_FALLBACK;
        weekdayIndex  = 0;

        // battery core
        lastBatteryTs     = 0;
        devBattery        = null;
        devBatteryStr     = BATT_FALLBACK;
        hasRealDevBattery = false;
        charging          = false;

        // tracking
        lastBattSamplePct = null;
        lastBattSampleTs  = 0;
        lastRatePerHour   = null;

        chargeStartTs     = 0;
        lastChargeEndTs   = 0;
        lastChargeDurMs   = 0;

        lastHeaderTs      = 0;
        lastChargingCheckTs = 0;
        // fixed lines
        headerStr   = HEADER_FALLBACK;
        topLine1Str = TOP1_FALLBACK;

        // custom slot (DEFAULT: Eff = 1 consigliato)
        topLine2Mode = 1;
        topLine2Str  = TOP2_FALLBACK;

        // optional internal caches
        timeToEmptyStr       = TOP2_FALLBACK;
        effScoreStr          = TOP2_FALLBACK;
        chargeSessionStr     = TOP2_FALLBACK;
        lastChargeElapsedStr = HEADER_FALLBACK;

        // first draw
        dirtyHeader     = true;
        dirtyTime       = true; 
        dirtyTopLines   = true;
        dirtyMid        = true;
        dirtyFooter     = true;
        needsFullRedraw = true;
    }

    function clearDirty() {
        dirtyHeader = false;
        dirtyTime     = false; 
        dirtyTopLines = false;
        dirtyMid    = false;
        dirtyFooter = false;
    }
}
