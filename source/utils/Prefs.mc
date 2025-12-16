using Toybox.Application;

module Prefs {

    var use24h = true;

    function load() {
        var app = Application.getApp();
        var v = app.getProperty("UseMilitaryFormat");

        // boolean può arrivare null -> default true/false come vuoi
        use24h = (v != null && v == true);
    }
}
