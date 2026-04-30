using Toybox.System;

module Log {

    // Metti a true solo in fase di debug locale
    const ENABLE_DEBUG = false;

    // Debug log (disattivato in release)
    function dbg(msg) {
        if (ENABLE_DEBUG) {
            System.println("D: " + msg);
        }
    }

    // Error log (sempre attivo, anche in release)
    function e(msg) {
        System.println("E: " + msg);
    }

}
