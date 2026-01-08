using Toybox.Graphics;

class GreenTeaTimer extends TeaTimer {
    function initialize() {
        TeaTimer.initialize("Green", 120, Graphics.COLOR_GREEN, 80);
    }
}
