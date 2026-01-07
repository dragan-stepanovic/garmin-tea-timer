using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.Attention;

var timerView;

class TeaTimerApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        timerView = new TeaTimerView();
        return [timerView, new TeaTimerDelegate()];
    }
}

class TeaTimerView extends WatchUi.View {
    const INITIAL_SECONDS = 1;
    var secondsRemaining = INITIAL_SECONDS;
    var timer;

    function initialize() {
        View.initialize();
        timer = new Timer.Timer();
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
        if (secondsRemaining > 0) {
            secondsRemaining -= 1;
            if (secondsRemaining == 0) {
                Attention.vibrate([
                    new Attention.VibeProfile(100, 500),
                    new Attention.VibeProfile(0, 300),
                    new Attention.VibeProfile(100, 500),
                    new Attention.VibeProfile(0, 300),
                    new Attention.VibeProfile(100, 500)
                ]);
                Attention.playTone(Attention.TONE_ALARM);
            }
        }
        WatchUi.requestUpdate();
    }

    function restart() {
        secondsRemaining = INITIAL_SECONDS;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var minutes = secondsRemaining / 60;
        var seconds = secondsRemaining % 60;
        var timeString = minutes + ":" + seconds.format("%02d");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_LARGE,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

class TeaTimerDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        if (timerView.secondsRemaining == 0) {
            timerView.restart();
        }
        return true;
    }
}
