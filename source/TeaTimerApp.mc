using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.Attention;

var timerView;

// Tea types: [name, seconds] - using short times for testing
var teaTypes = [
    ["Green", 3],
    ["Black", 5]
];
var currentTeaIndex = 0;

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
    var secondsRemaining;
    var timer;
    var isRunning = false;

    function initialize() {
        View.initialize();
        secondsRemaining = teaTypes[currentTeaIndex][1];
        timer = new Timer.Timer();
    }

    function startTimer() {
        isRunning = true;
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
        if (secondsRemaining > 0) {
            secondsRemaining -= 1;
            if (secondsRemaining == 0) {
                isRunning = false;
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
        secondsRemaining = teaTypes[currentTeaIndex][1];
        isRunning = false;
        timer.stop();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var teaName = teaTypes[currentTeaIndex][0];
        var minutes = secondsRemaining / 60;
        var seconds = secondsRemaining % 60;
        var timeString = minutes + ":" + seconds.format("%02d");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Tea name
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - 40,
            Graphics.FONT_MEDIUM,
            teaName,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Time
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 + 20,
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
        } else if (!timerView.isRunning) {
            timerView.startTimer();
        }
        return true;
    }

    function onNextPage() {
        if (!timerView.isRunning) {
            currentTeaIndex = (currentTeaIndex + 1) % teaTypes.size();
            timerView.restart();
        }
        return true;
    }

    function onPreviousPage() {
        if (!timerView.isRunning) {
            currentTeaIndex = (currentTeaIndex - 1 + teaTypes.size()) % teaTypes.size();
            timerView.restart();
        }
        return true;
    }
}
