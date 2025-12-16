using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.Battery;
using Toybox.SensorHistory;
using Log;

module Metrics {

    // -------------------------------------------------
    //  BATTERIA DEVICE
    // -------------------------------------------------
    function getDeviceBatteryPercent() {
        try {
            var status = System.getSystemStats();
            if (status != null && status.battery != null) {
                return status.battery; // 0..100
            }
        } catch (e) {
            Log.dbg("getDeviceBatteryPercent: " + e);
        }
        return null;
    }

}
