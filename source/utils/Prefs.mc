using Toybox.Application;

module Prefs {

    var use24h = true;
    var top2Mode = 1; 

    function load() {
        var app = Application.getApp();
        var v = app.getProperty("UseMilitaryFormat");

        // boolean può arrivare null -> default true/false come vuoi
        use24h = (v != null && v == true);

        var m = app.getProperty("top2Mode");
        if (m != null) {
            try {
                top2Mode = m.toNumber();
            } catch(e) {
                top2Mode = 1;
            }
        } else {
            top2Mode = 1;
        }
    }
}
