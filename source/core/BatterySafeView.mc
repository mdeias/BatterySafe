import Toybox.Application;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;
import Log;

using GraphicsManager;

class BatterySafeView extends WatchUi.WatchFace {

    var _state;
    var _dataManager;

    function initialize() {
        WatchFace.initialize();

        Log.dbg("BatterySafeView.initialize");

        _state = new State();
        _dataManager = new DataManager(_state);
    }

    function onLayout(dc as Dc) as Void {
        Log.dbg("BatterySafeView.onLayout");
        // no XML layout
    }

    function getRefreshRate() {
        // 1 update al minuto
        return 60 * 1000;
    }

    function onUpdate(dc as Dc) as Void {

        try {
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

    // Wake: refresh immediato dei dati "vivi"
    function onExitSleep() as Void {

        Log.e("BatterySafeView.onExitSleep");

        if (_dataManager == null) {
            return;
        }

        var nowMs = System.getTimer();

        // refresh immediato SOLO di ciò che ha senso
        _dataManager.refreshStepsIfNeeded(nowMs, true);
        _dataManager.refreshBatteryIfNeeded(nowMs, true);

        // segna dirty: header (steps) + footer (battery)
        _state.dirtyHeader = true;
        _state.dirtyFooter = true;

        // IMPORTANTISSIMO:
        // dopo sleep / wake il framebuffer può non contenere più
        // tutte le parti statiche "stampate".
        // La soluzione più sicura (zero regressioni) è forzare 1 full redraw.
        _state.needsFullRedraw = true;
    }

    function onEnterSleep() as Void {
        Log.dbg("BatterySafeView.onEnterSleep");
    }
}
