using Toybox.Graphics as G;

// Module, non class
module FontManager {

    // Facce Roboto-like disponibili su molti device
    const ROBOTO_REGULAR_FACES = [
        "BionicBold",
        "Swiss721Regular"
    ];

    const ROBOTO_BOLD_FACES = [
        "BionicBold",
        "Swiss721Bold"
    ];

    // Cache { "b16" => font, "r14" => font, ... }
    var _cache = {};

    // size = dimensione in px, bold = true/false
    function getRoboto(size, bold) {

        var key = (bold ? "b" : "r") + size;

        if (_cache != null && _cache.hasKey(key)) {
            return _cache[key];
        }

        var font = null;

        // Se il device supporta i vector font, proviamo a usarli
        if (G has :getVectorFont) {
            var faces;

            if (bold) {
                faces = ROBOTO_BOLD_FACES;
            } else {
                faces = ROBOTO_REGULAR_FACES;
            }

            try {
                font = G.getVectorFont({
                    :face => faces,
                    :size => size
                });
            } catch(e) {
                // se fallisce, font resta null e sotto usiamo il fallback
            }
        }

        // Fallback: font di sistema approssimato per dimensione
        if (font == null) {
            if (size <= 12) {
                font = G.FONT_XTINY;
            } else if (size <= 16) {
                font = G.FONT_TINY;
            } else if (size <= 22) {
                font = G.FONT_SMALL;
            } else if (size <= 30) {
                font = G.FONT_MEDIUM;
            } else {
                font = G.FONT_LARGE;
            }
        }

        if (_cache == null) {
            _cache = {};
        }

        _cache[key] = font;
        return font;
    }

    function roboto(size) {
        return getRoboto(size, false);
    }

    function robotoBold(size) {
        return getRoboto(size, true);
    }
}
