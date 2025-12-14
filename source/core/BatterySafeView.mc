import Toybox.Application;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;
import Log;

using GraphicsManager;

class BatterySafeView extends WatchUi.WatchFace {

    var _state;
    var _dataManager;
    var _aodShiftX;
    var _aodShiftY;
    var _aodLastSlot;
    var _isLowPower;
    var _didDrawAod;


    function initialize() {
        WatchFace.initialize();

        _isLowPower = false;
        _didDrawAod = false;
        _aodShiftX = 0;
        _aodShiftY = 0;
        _aodLastSlot = -1;
        _state = new State();
        _dataManager = new DataManager(_state);
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

            var nowMs = System.getTimer();
            // -----------------------------
            // Refresh dati (scheduler)
            // -----------------------------
            if (_dataManager != null) {
                _dataManager.refreshFast();
                _dataManager.refreshStepsIfNeeded(nowMs, false);
                _dataManager.refreshBatteryIfNeeded(nowMs, false);
                _dataManager.refreshBodyBatteryIfNeeded(nowMs);
            }

            // -----------------------------
            // Time cache (solo se cambia minuto)
            // -----------------------------
            var ct = System.getClockTime();
            var minuteKey = (ct.hour * 60) + ct.min;

            if (minuteKey != _state.lastMinuteKey) {
                _state.lastMinuteKey = minuteKey;
                _state.timeStr = ct.hour.format("%02d") + ":" + ct.min.format("%02d");
                _state.dirtyTop = true;
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

            if (_state.dirtyTop) {
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
            _dataManager.refreshStepsIfNeeded(nowMs, true);
            _dataManager.refreshBatteryIfNeeded(nowMs, true);
        }

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



}
