using Toybox.System;
using Toybox.Time;
using Toybox.Math;
using Metrics;

class DataManager {

    const BAT_REFRESH_MS    = 15 * 60 * 1000; // 15 min (sampling batteria + trend)
    const HEADER_REFRESH_MS = 60 * 60 * 1000; // 60 min (Last charge elapsed)
    const CHG_REFRESH_MS = 5 * 60 * 1000; // 5 min (charging state)
    // Top2 mode (decidi tu dove settarlo: settings o default nello State)
    const TOP2_TTE = 0;
    const TOP2_EFF = 1;
    const TOP2_CHG = 2;

    var _state as State;

    function initialize(state as State) {
        _state = state;

        // Date iniziale
        refreshDateIfNeeded();
    }

    public function getBatteryRefreshMs() { return BAT_REFRESH_MS; }

    // chiamala ad ogni onUpdate (economica)
    function refreshFast(nowMs) {
        refreshDateIfNeeded();

        // 1) Charging state ogni 5 minuti (low cost)
        refreshChargingIfNeeded(nowMs);

        // 2) Header può aggiornare anche senza battery sample
        refreshHeaderIfNeeded(nowMs, false);

        // 3) Se top2 è CHG, aggiorna ogni minuto
        if (_state.charging && _state.topLine2Mode == TOP2_CHG) {
            updateTop2Custom(nowMs);
        }
    }


    function refreshBatteryIfNeeded(nowMs, force) {
        // anche se non campioniamo batteria, header può aggiornare ogni ora
        if (!force && _state.lastBatteryTs != 0 && (nowMs - _state.lastBatteryTs) < BAT_REFRESH_MS) {
            refreshHeaderIfNeeded(nowMs, false);
            return;
        }

        _state.lastBatteryTs = nowMs;

        // ----------------------------
        // 1) Letture low-cost
        // ----------------------------
        var pct = Metrics.getDeviceBatteryPercent();
        if (pct == null) {
            refreshHeaderIfNeeded(nowMs, false);
            return;
        }

        var chargingNow = _state.charging;
        try {
            var stats = System.getSystemStats();
            if (stats != null && (stats has :charging)) {
                chargingNow = stats.charging;
            }
        } catch(e) { }

        // ----------------------------
        // 2) Charging transitions (inizio/fine carica)
        // ----------------------------
        handleChargingTransitions(nowMs, chargingNow);

        // ----------------------------
        // 3) Footer: % batteria
        // ----------------------------
        updateDeviceBatteryFromPct(pct);

        // ----------------------------
        // 4) Top1: trend Δ%/h
        // ----------------------------
        updateBatteryTrend(nowMs, pct);

        // ----------------------------
        // 5) Header: Last charge elapsed (ogni ora, o subito dopo unplug)
        // ----------------------------
        refreshHeaderIfNeeded(nowMs, true);

        // ----------------------------
        // 6) Top2: custom (eff default / chg duration / tte)
        // ----------------------------
        updateTop2Custom(nowMs);
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

        var dow = dinfo.day_of_week;
        _state.weekdayIndex = (dow + 5) % 7; // -> 0..6 (Mo..Su)

        _state.dirtyMid = true;
    }

    // ----------------------------
    // Footer battery: usa pct già letto
    // ----------------------------
    function updateDeviceBatteryFromPct(pct) {

        _state.devBattery = pct;
        _state.hasRealDevBattery = true;

        var newStr = pct.format("%d") + "%";
        if (_state.devBatteryStr != newStr) {
            _state.devBatteryStr = newStr;
            _state.dirtyFooter = true;
        }
    }

    // ----------------------------
    // Charging transitions
    // ----------------------------
    function handleChargingTransitions(nowMs, chargingNow) {

        // se non era mai inizializzato, set e basta
        if (_state.charging == null) {
            _state.charging = chargingNow;
            if (chargingNow) {
                _state.chargeStartTs = nowMs;
            }
            return;
        }

        if (chargingNow == _state.charging) {
            return;
        }

        // transizione
        var old = _state.charging;
        _state.charging = chargingNow;

        if (chargingNow) {
            // entra in charging
            _state.chargeStartTs = nowMs;

        } else {
            // esce da charging (unplug)
            _state.lastChargeEndTs = nowMs;

            if (_state.chargeStartTs != 0 && nowMs > _state.chargeStartTs) {
                _state.lastChargeDurMs = nowMs - _state.chargeStartTs;
            }
            _state.chargeStartTs = 0;

            // forza header refresh immediato
            _state.lastHeaderTs = 0;
        }
    }

    // ----------------------------
    // Top1: Battery trend Δ%/h
    // ----------------------------
    function updateBatteryTrend(nowMs, pct) {

        if (_state.lastBattSampleTs == 0 || _state.lastBattSamplePct == null) {
            _state.lastBattSampleTs  = nowMs;
            _state.lastBattSamplePct = pct;
            _state.lastRatePerHour   = null;
            setTop1("Use: --");
            return;
        }

        var dt = nowMs - _state.lastBattSampleTs;
        if (dt < BAT_REFRESH_MS) {
            return;
        }

        var hours = (dt.toFloat() / 3600000.0);
        if (hours <= 0) { return; }

        var dp = (pct - _state.lastBattSamplePct).toFloat();

        // Se la percentuale non cambia dopo la finestra, assumiamo rate=0
        if (dp == 0) {
            _state.lastBattSampleTs  = nowMs;
            _state.lastBattSamplePct = pct;
            _state.lastRatePerHour   = 0.0;

            setTop1("Use: 0.0%");
            return;
        }

        var rate = dp / hours; // %/h

        _state.lastBattSampleTs  = nowMs;
        _state.lastBattSamplePct = pct;
        _state.lastRatePerHour   = rate;

        // 1 decimal rounding using *10 integer
        var r10 = (rate * 10.0);
        var rounded10 = (r10 >= 0) ? (r10 + 0.5) : (r10 - 0.5);
        rounded10 = rounded10.toNumber();

        var abs10 = (rounded10 < 0) ? -rounded10 : rounded10;
        var ip  = (abs10 / 10).toNumber();
        var dp1 = (abs10 % 10).toNumber();

        var val = ip.format("%d") + "." + dp1.format("%d") + "%";

        if (rounded10 < 0) {
            setTop1("Use: " + val);
        } else if (rounded10 > 0) {
            setTop1("Chg: " + val);
        } else {
            setTop1("Use: 0.0%");
        }
    }

    function setTop1(str) {
        if (str == null) { str = "Use: --"; }
        if (_state.topLine1Str != str) {
            _state.topLine1Str = str;
            _state.dirtyTopLines = true;

        }
    }


    // ----------------------------
    // Header: Last charge elapsed
    // ----------------------------
    function refreshHeaderIfNeeded(nowMs, force) {

        if (!force && _state.lastHeaderTs != 0 && (nowMs - _state.lastHeaderTs) < HEADER_REFRESH_MS) {
            return;
        }

        _state.lastHeaderTs = nowMs;

        var s = "Since charge: --";

        if (_state.lastChargeEndTs != 0 && nowMs > _state.lastChargeEndTs) {
            s = "Since charge: " + _fmtDH(nowMs - _state.lastChargeEndTs);
        }

        if (_state.headerStr != s) {
            _state.headerStr = s;
            _state.dirtyHeader = true;
        }
    }

    // ----------------------------
    // Top2: custom
    // TOP2_EFF default, TOP2_CHG, TOP2_TTE
    // ----------------------------
    function updateTop2Custom(nowMs) {

        // se non lo hai ancora nello State, tienilo fisso a EFF
        var mode = (_state has :topLine2Mode) ? _state.topLine2Mode : TOP2_EFF;

        var out = "--";

        if (mode == TOP2_CHG) {

            if (_state.charging && _state.chargeStartTs != 0 && nowMs > _state.chargeStartTs) {
                out = "Charging: " + _fmtDH(nowMs - _state.chargeStartTs);
            } else if (_state.lastChargeDurMs != 0) {
                out = "Charging: " + _fmtDH(_state.lastChargeDurMs);
            } else {
                out = "Charging: --";
            }

        } else {

            var rate = _state.lastRatePerHour; // Float
            if (rate == null) {

                out = (mode == TOP2_TTE) ? "Remaining: --" : "Score: --";

            } else {

                if (mode == TOP2_TTE) {
                    out = formatTte(rate);
                } else {
                    out = formatEff(rate);
                }
            }
        }

        if (_state.topLine2Str != out) {
            _state.topLine2Str = out;
            _state.dirtyTopLines = true;
        }
    }

    function formatEff(rate) {
        // consumo: rate negativo => cons positivo
        if (rate > 0) { return "Score: --"; }  // in carica non ha senso valutare
        var cons = (rate < 0) ? -rate : 0.0;   // rate==0 => cons=0

        var grade = "E";
        if (cons <= 0.7) { grade = "A"; }
        else if (cons <= 1.2) { grade = "B"; }
        else if (cons <= 2.0) { grade = "C"; }
        else if (cons <= 3.0) { grade = "D"; }

        return "Score: " + grade;
    }

    function formatTte(rate) {
        if (rate >= 0) { return "Left: --"; }
        if (_state.devBattery == null) { return "Left: --"; }

        var cons = -rate; // %/h
        if (cons <= 0) { return "Left: --"; }

        var hours = (_state.devBattery.toFloat() / cons);
        var totalMin = (hours * 60.0).toNumber();

        var d = (totalMin / (60 * 24)).toNumber();
        var h = ((totalMin - d * 60 * 24) / 60).toNumber();

        return "Left: " + d.format("%d") + "d " + h.format("%d") + "h";
    }

    // ----------------------------
    // Formatter
    // ----------------------------
    function _fmtDH(ms) {
        if (ms <= 0) { return "--"; }
        var sec = (ms / 1000).toNumber();
        var min = (sec / 60).toNumber();
        var hr  = (min / 60).toNumber();
        var day = (hr / 24).toNumber();

        hr  = hr % 24;
        min = min % 60;

        if (day > 0) {
            return day.format("%dd") + " " + hr.format("%dh");
        }
        return hr.format("%dh") + " " + min.format("%dm");
    }

    function refreshChargingIfNeeded(nowMs) {

        // throttle: controlla charging solo ogni CHG_REFRESH_MS
        if (_state.lastChargingCheckTs != 0 &&
            (nowMs - _state.lastChargingCheckTs) < CHG_REFRESH_MS) {
            return;
        }

        _state.lastChargingCheckTs = nowMs;

        var chargingNow = _state.charging;

        try {
            var stats = System.getSystemStats();
            if (stats != null && (stats has :charging)) {
                chargingNow = stats.charging;
            }
        } catch(e) { }

        handleChargingTransitions(nowMs, chargingNow);
    }


}
