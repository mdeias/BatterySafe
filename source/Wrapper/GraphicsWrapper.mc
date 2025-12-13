using Toybox.Graphics;
using FontManager;

module GraphicsManager {

    const BASE_SIZE = 390.0;

    var _headerRenderer;
    var _midCenterRenderer;
    var _topCenterRenderer;
    var _footerRenderer;

    function init() {
        // meglio istanziare solo se null,
        // così non ricrei tutto ogni volta
        if (_headerRenderer == null) {
            _headerRenderer    = new HeaderRenderer();
            _midCenterRenderer = new MidCenterRenderer();
            _topCenterRenderer = new TopCenterRenderer();
            _footerRenderer    = new FooterRenderer();
        }
    }

    function getScale(dc as Graphics.Dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var minSide = (w < h) ? w : h;
        return minSide / BASE_SIZE;
    }

    function drawHeader(dc as Graphics.Dc, state as State) {
        if (_headerRenderer == null) { init(); }
        var s = getScale(dc);
        _headerRenderer.draw(dc, state, s);
    }

    function drawTopCenter(dc as Graphics.Dc, state as State) {
        if (_topCenterRenderer == null) { init(); }
        var s = getScale(dc);
        _topCenterRenderer.draw(dc, state, s);
    }

    function drawMidCenter(dc as Graphics.Dc, state as State) {
        if (_midCenterRenderer == null) { init(); }
        var s = getScale(dc);
        _midCenterRenderer.draw(dc, state, s);
    }

    function drawFooter(dc as Graphics.Dc, state as State) {
        if (_footerRenderer == null) { init(); }
        var s = getScale(dc);
        _footerRenderer.draw(dc, state, s);
    }

}
