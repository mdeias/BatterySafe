using Toybox.System;
using Toybox.Time;
using Toybox.Math;
using Metrics;

class DataManager {

    const STEPS_REFRESH_MS = 5 * 60 * 1000;  // 5 min
    const BB_REFRESH_MS    = 3 * 60 * 1000;  // 3 min
    const BAT_REFRESH_MS   = 10 * 60 * 1000; // 10 min

    var _state as State;

    function initialize(state as State) {
        _state = state;

        // Touch: capability -> una volta
        readTouchCapability();

        // Date iniziale
        refreshDateIfNeeded();
    }

    // chiamala ad ogni onUpdate (economica)
    function refreshFast() {
        refreshDateIfNeeded();
    }

    function refreshStepsIfNeeded(nowMs, force) {
        if (!force && _state.lastStepsTs != 0 && (nowMs - _state.lastStepsTs) < STEPS_REFRESH_MS) {
            return;
        }
        _state.lastStepsTs = nowMs;
        updateSteps();
    }

    function refreshBatteryIfNeeded(nowMs, force) {
        if (!force && _state.lastBatteryTs != 0 && (nowMs - _state.lastBatteryTs) < BAT_REFRESH_MS) {
            return;
        }
        _state.lastBatteryTs = nowMs;
        updateDeviceBattery();
    }

    function refreshBodyBatteryIfNeeded(nowMs) {
        if (_state.lastBodyBatteryTs != 0 && (nowMs - _state.lastBodyBatteryTs) < BB_REFRESH_MS) {
            return;
        }
        _state.lastBodyBatteryTs = nowMs;
        updateBodyBattery();
    }

    // ----------------------------
    // DATE + WEEKDAY (solo cambio giorno)
    // ----------------------------
    function refreshDateIfNeeded() {

        var dinfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        var dateKey = (dinfo.year * 10000) + (dinfo.month * 100) + dinfo.day;
        if (dateKey == _state.lastDateKey) {
            return;
        }

        _state.lastDateKey = dateKey;

        _state.dateStr =
            dinfo.day.format("%02d") + "-" +
            dinfo.month.format("%02d") + "-" +
            dinfo.year.format("%04d");

        // Nel tuo caso: day_of_week è 1..7 (Su..Sa)
        var dow = dinfo.day_of_week;
        _state.weekdayIndex = (dow + 5) % 7; // -> 0..6 (Mo..Su)

        // Mid cambia (data + highlight weekday)
        _state.dirtyMid = true;
    }

    // ----------------------------
    // TOUCH (capability)
    // ----------------------------
    function readTouchCapability() {
        try {
            var settings = System.getDeviceSettings();
            if (settings != null && (settings has :isTouchScreen)) {

                var old = _state.isTouchScreen;

                _state.isTouchScreen        = settings.isTouchScreen;
                _state.hasRealIsTouchScreen = true;

                // string cache (✓ / ×)
                _state.touchStr = _state.isTouchScreen ? "Touch: ✓" : "Touch: ×";

                // se cambia (di solito no) sporca Top
                if (old == null || old != _state.isTouchScreen) {
                    _state.dirtyTop = true;
                }
            }
        } catch (e) {
            // fallback se non disponibile
            if (!_state.hasRealIsTouchScreen) {
                _state.touchStr = "Touch: --";
            }
        }
    }

    // ----------------------------
    // DEVICE BATTERY
    // ----------------------------
    function updateDeviceBattery() {

        var old = _state.devBattery;
        var v = Metrics.getDeviceBatteryPercent();

        if (v == null) {
            // manteniamo l'ultimo valido
            return;
        }

        _state.devBattery        = v;
        _state.hasRealDevBattery = true;

        var newStr = v.format("%d") + "%";
        if (_state.devBatteryStr != newStr) {
            _state.devBatteryStr = newStr;
            _state.dirtyFooter = true;
        } else {
            // anche se il numero è uguale, niente redraw
        }

        // se vuoi essere super-safe: se cambia valore numerico, sporca footer
        if (old == null || old != v) {
            _state.dirtyFooter = true;
        }
    }

    // ----------------------------
    // STEPS
    // ----------------------------
    function updateSteps() {

        var data = Metrics.getStepsAndGoal();
        if (data == null) {
            return;
        }

        var steps = data[:steps];
        var goal  = data[:goal];

        if (steps == null || goal == null || goal <= 0) {
            return;
        }

        var oldSteps = _state.steps;
        var oldPct   = _state.stepsPercent;

        var pct = (steps * 100) / goal;

        _state.steps        = steps;
        _state.stepGoal     = goal;
        _state.stepsPercent = pct;
        _state.hasRealSteps = true;

        // string cache unica per Header: "ST: 1234 -> 56%"
        var newStr = "ST: " + steps.format("%d") + " -> " + pct.format("%d") + "%";
        if (_state.stepsLineStr != newStr) {
            _state.stepsLineStr = newStr;
            _state.dirtyHeader = true;
        } else if (oldSteps == null || oldSteps != steps || oldPct == null || oldPct != pct) {
            _state.dirtyHeader = true;
        }
    }

    // ----------------------------
    // BODY BATTERY
    // ----------------------------
    function updateBodyBattery() {

        var old = _state.bodyBattery;
        var bb = Metrics.getBodyBattery();

        if (bb == null) {
            return;
        }

        _state.bodyBattery        = bb;
        _state.hasRealBodyBattery = true;

        var newStr = "BB: " + bb.format("%d");
        if (_state.bodyBatteryStr != newStr) {
            _state.bodyBatteryStr = newStr;
            _state.dirtyTop = true; // BB è in TopCenter
        } else if (old == null || old != bb) {
            _state.dirtyTop = true;
        }
    }
}
