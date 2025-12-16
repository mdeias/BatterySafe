using Toybox.System;
using Log;

module Metrics {

    // -------------------------------------------------
    //  BATTERIA DEVICE
    // -------------------------------------------------

    function getDeviceBatteryPercent() {
        try {
            var stats = System.getSystemStats();
            if (stats != null && (stats has :battery)) {
                return stats.battery; // Number 0..100
            }
        } catch (e) { }
        return null;
    }
    function getIsCharging() {
        try {
            var stats = System.getSystemStats();
            if (stats != null && (stats has :charging)) {
                return stats.charging; // Bool
            }
        } catch (e) { }
        return null;
    }
}

