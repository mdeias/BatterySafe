import Toybox.Application;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;
import Log;
import Prefs;

using GraphicsManager;

class BatterySafeView extends WatchUi.WatchFace {

    var _state;
    var _dataManager;
    var _aodShiftX;
    var _aodShiftY;
    var _aodLastSlot;
    var _isLowPower;
    var _didDrawAod;
    var _lastSettingsVersion;

    function initialize() {
        WatchFace.initialize();

        _isLowPower = false;
        _didDrawAod = false;
        _aodShiftX = 0;
        _aodShiftY = 0;
        _aodLastSlot = -1;
        _lastSettingsVersion = -1;
        _state = new State();
        _dataManager = new DataManager(_state);
        Palette.load();
    }

    function onLayout(dc as Dc) as Void {
        // no XML layout
    }

    function getRefreshRate() {
        // 1 update al minuto
        return 60 * 1000;
    }

    function onUpdate(dc as Dc) as Void {

        try {
            if (_isLowPower) {
                _didDrawAod = true;
                var s = GraphicsManager.getScale(dc);
                var nowMs = System.getTimer();
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();
                updateAodShift(nowMs, s);
                GraphicsManager.drawAodTime(dc, _state, _aodShiftX, _aodShiftY);
                GraphicsManager.drawAodDate(dc, _state, _aodShiftX, _aodShiftY);
                return;
            }
            applySettingsIfNeeded();
            var nowMs = System.getTimer();
            // -----------------------------
            // Refresh dati (scheduler)
            // -----------------------------
            if (_dataManager != null) {
                _dataManager.refreshFast(nowMs);

                // Chiama la parte "battery sample" solo quando serve davvero
                var needBattery = (_state.lastBatteryTs == 0) ||
                                  ((nowMs - _state.lastBatteryTs) >= _dataManager.getBatteryRefreshMs());

                if (needBattery) {
                    _dataManager.refreshBatteryIfNeeded(nowMs, false);
                }
            }


            // -----------------------------
            // Time cache (solo se cambia minuto)
            // -----------------------------
            var ct = System.getClockTime();
            var minuteKey = (ct.hour * 60) + ct.min;

            if (minuteKey != _state.lastMinuteKey) {
                _state.lastMinuteKey = minuteKey;

                    var hh = ct.hour;

                    if (!Prefs.use24h) {
                        hh = hh % 12;
                        if (hh == 0) { hh = 12; }
                    }
                    
                    _state.timeStr = hh.format("%02d") + ":" + ct.min.format("%02d");

                _state.dirtyTime = true;
            }

            // -----------------------------
            // FULL REDRAW
            // (prima volta, o quando lo forziamo dopo sleep / ecc.)
            // -----------------------------
            if (_state.needsFullRedraw) {

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                GraphicsManager.drawHeader(dc, _state);
                GraphicsManager.drawTopCenter(dc, _state);
                GraphicsManager.drawMidCenter(dc, _state);
                GraphicsManager.drawFooter(dc, _state);

                _state.needsFullRedraw = false;
                _state.clearDirty();
                return;
            }

            // -----------------------------
            // PARTIAL REDRAW (solo sezioni dirty)
            // -----------------------------
            if (_state.dirtyHeader) {
                GraphicsManager.drawHeader(dc, _state);
            }

            if (_state.dirtyTime || _state.dirtyTopLines) {
                GraphicsManager.drawTopCenter(dc, _state);
            }

            if (_state.dirtyMid) {
                GraphicsManager.drawMidCenter(dc, _state);
            }

            if (_state.dirtyFooter) {
                GraphicsManager.drawFooter(dc, _state);
            }

            _state.clearDirty();

        } catch (e) {
            Log.dbg("BatterySafeView.onUpdate EXCEPTION=" + e);
        }
    }

    function onShow() as Void {
        Log.dbg("BatterySafeView.onShow");

        // Per sicurezza: quando la view torna in foreground,
        // ristampiamo tutto una volta.
        _state.needsFullRedraw = true;
    }

    function onHide() as Void {
        Log.dbg("BatterySafeView.onHide");
    }

    function onEnterSleep() as Void {
        _isLowPower = true;
        WatchUi.WatchFace.onEnterSleep();
    }

    function onExitSleep() as Void {
        _isLowPower = false;
        WatchUi.WatchFace.onExitSleep();

        if (_didDrawAod) {
            GraphicsManager.invalidateStatic();
            _state.needsFullRedraw = true;
            _didDrawAod = false;
        }

        if (_dataManager != null) {
            var nowMs = System.getTimer();
            _dataManager.refreshBatteryIfNeeded(nowMs, true);
        }
        _state.dirtyTime = true;
        _state.dirtyHeader = true;
        _state.dirtyFooter = true;
    }

    function onPartialUpdate(dc as Graphics.Dc) {

        // AOD: sfondo nero SEMPRE (come Recovery) -> elimina residui
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    function updateAodShift(nowMs, s) {

        // cambia ogni 10 minuti
        var slot = (nowMs / 600000).toNumber();
        if (slot == _aodLastSlot) { return; }

        _aodLastSlot = slot;

        var d = 2.0 * s; // ampiezza shift (max 2px * scale)
        var m = slot % 4;

        if (m == 0) { _aodShiftX = 0;  _aodShiftY = 0; }
        if (m == 1) { _aodShiftX = d;  _aodShiftY = 0; }
        if (m == 2) { _aodShiftX = 0;  _aodShiftY = d; }
        if (m == 3) { _aodShiftX = d;  _aodShiftY = d; }
    }

    function applySettingsIfNeeded() {

        if (_lastSettingsVersion == SettingsBus.version) { return; }
        _lastSettingsVersion = SettingsBus.version;

        Palette.load();
        Prefs.load();
        _state.lastMinuteKey = -1;

        GraphicsManager.invalidateStatic();
        _state.dirtyTime = true;
        _state.dirtyTopLines = true;
        _state.dirtyHeader = true;
        _state.dirtyMid = true;
        _state.dirtyFooter = true;
        _state.needsFullRedraw = true;
    }

}
