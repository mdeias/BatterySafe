using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.Battery;
using Toybox.SensorHistory;

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
            // Log.e("getDeviceBatteryPercent: " + e);
        }
        return null;
    }

    // -------------------------------------------------
    //  TOUCH ATTIVATO
    // -------------------------------------------------
    function getIsTouchScreen() {
        try {
            var settings = System.getDeviceSettings();
            if (settings != null ) {
                return settings.isTouchScreen; // 0..100
            }
        } catch (e) {
            // Log.e("getPhoneBatteryPercent: " + e);
        }
        return null;
    }

    // -------------------------------------------------
    //  PASSI + OBIETTIVO
    // -------------------------------------------------
    function getStepsAndGoal() {
        try {
            if (!(Toybox has :ActivityMonitor)) {
                return { :steps => null, :goal => null };
            }

            var info = ActivityMonitor.getInfo();
            if (info == null) {
                return { :steps => null, :goal => null };
            }

            var steps = info.steps;
            var goal  = info.stepGoal;

            return { :steps => steps, :goal => goal };

        } catch (e) {
            // Log.e("getStepsAndGoal: " + e);
            return { :steps => null, :goal => null };
        }
    }

    // -------------------------------------------------
    //  BODY BATTERY (ultimo valore valido negli ultimi 60')
    // -------------------------------------------------
    function getBodyBattery() {
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getBodyBatteryHistory)) {
                return null;
            }

            // ultimi 60 minuti
            var it = SensorHistory.getBodyBatteryHistory({ :period => 60 });
            if (it == null) {
                return null;
            }

            var sample    = it.next();
            var lastValid = null;

            while (sample != null) {
                if (sample.data != null) {
                    lastValid = sample.data; // 0..100
                }
                sample = it.next();
            }

            return lastValid;

        } catch (e) {
            // Log.e("getBodyBattery: " + e);
            return null;
        }
    }

}
