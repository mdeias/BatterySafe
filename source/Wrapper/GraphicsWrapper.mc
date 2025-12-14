using Toybox.Graphics;
using FontManager;

module GraphicsManager {

    const BASE_SIZE = 390.0;

    var _headerRenderer;
    var _midCenterRenderer;
    var _topCenterRenderer;
    var _footerRenderer;

    function init() {
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

    function drawAodTime(dc as Graphics.Dc, state as State, shiftX, shiftY) {
        if (_topCenterRenderer == null) { init(); }
        var s = getScale(dc);
        _topCenterRenderer.drawAodTime(dc, state, s, shiftX, shiftY);
    }

    function drawAodDate(dc as Graphics.Dc, state as State, shiftX, shiftY) {
        if (_midCenterRenderer == null) { init(); }
        var s = getScale(dc);
        _midCenterRenderer.drawAodDate(dc, state, s, shiftX, shiftY);
    }

    function invalidateStatic() {
        if (_headerRenderer != null && (_headerRenderer has :invalidateStatic)) { _headerRenderer.invalidateStatic(); }
        if (_topCenterRenderer != null && (_topCenterRenderer has :invalidateStatic)) { _topCenterRenderer.invalidateStatic(); }
        if (_midCenterRenderer != null && (_midCenterRenderer has :invalidateStatic)) { _midCenterRenderer.invalidateStatic(); }
        if (_footerRenderer != null && (_footerRenderer has :invalidateStatic)) { _footerRenderer.invalidateStatic(); }
    }


}
