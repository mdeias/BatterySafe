using Toybox.Graphics as G;
using Toybox.Math;

module FontManager {

    const ROBOTO_BOLD_FACES = [
        "BionicBold",
        "RobotoCondensedBold"
    ];

    var _cache = {};

    function robotoBold(size) {

        var s = Math.round(size);
        var key = "b" + s;

        if (_cache.hasKey(key)) {
            return _cache[key];
        }

        var font = null;

        if (G has :getVectorFont) {
            try {
                font = G.getVectorFont({
                    :face => ROBOTO_BOLD_FACES,
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
}
