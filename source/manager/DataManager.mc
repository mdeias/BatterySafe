using Toybox.System;
using Toybox.Time;
using Toybox.Math;
using Metrics;

class DataManager {

    const STEPS_REFRESH_MS = 5 * 60 * 1000;  // 5 min
    const BB_REFRESH_MS = 30 * 60 * 1000;
    const BAT_REFRESH_MS   = 15 * 60 * 1000; // 15 min

    var _state as State;

    function initialize(state as State) {
        _state = state;

        // Date iniziale
        refreshDateIfNeeded();
    }

    // chiamala ad ogni onUpdate (economica)
    function refreshFast() {
        refreshDateIfNeeded();
    }

    function refreshBatteryIfNeeded(nowMs, force) {
        if (!force && _state.lastBatteryTs != 0 && (nowMs - _state.lastBatteryTs) < BAT_REFRESH_MS) {
            return;
        }
        _state.lastBatteryTs = nowMs;
        updateDeviceBattery();
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
    // DEVICE BATTERY
    // ----------------------------
    function updateDeviceBattery() {
        var v = Metrics.getDeviceBatteryPercent();
        if (v == null) { return; }

        _state.devBattery = v;
        _state.hasRealDevBattery = true;

        var newStr = v.format("%d") + "%";
        if (_state.devBatteryStr != newStr) {
            _state.devBatteryStr = newStr;
            _state.dirtyFooter = true;
        }
    }

}
