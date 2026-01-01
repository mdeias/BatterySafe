using Toybox.Graphics as G;
using Toybox.Math;

module FontManager {

    const ROBOTO_BOLD_FACES = [
        "RobotoCondensedBold"
    ];

    const BIONIC_NUM_FACES = [
        "BionicBold",
        "RobotoCondensedBold"
    ];

    var _cache = {};

    function boldNum(size) {
        return _get("n", size, BIONIC_NUM_FACES);
    }

    function boldText(size) {
        return _get("t", size, ROBOTO_BOLD_FACES);
    }

    function _get(prefix, size, faces) {

        var s = Math.round(size);
        var key = prefix + s;

        if (_cache.hasKey(key)) {
            return _cache[key];
        }

        var font = null;

        if (G has :getVectorFont) {
            try {
                font = G.getVectorFont({
                    :face => faces,
                    :size => s
                });
            } catch (e) {
                font = null;
            }
        }

        // fallback SICURO
        if (font == null) {
            if (s <= 12)      {font = G.FONT_XTINY;}
            else if (s <= 16) {font = G.FONT_TINY;}
            else if (s <= 22) {font = G.FONT_SMALL;}
            else if (s <= 30) {font = G.FONT_MEDIUM;}
            else              {font = G.FONT_LARGE;}
        }

        _cache[key] = font;
        return font;
    }

    // (opzionale) tieni robotoBold per compatibilità
    function robotoBold(size) {
        return boldText(size);
    }
}
