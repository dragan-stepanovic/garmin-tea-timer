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
        secondsRemaining = (teaTypes[currentTeaIndex] as Array)[1] as Number;
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
            }
        }
        WatchUi.requestUpdate();
    }

    function restart() {
        secondsRemaining = (teaTypes[currentTeaIndex] as Array)[1] as Number;
        isRunning = false;
        timer.stop();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var teaName = (teaTypes[currentTeaIndex] as Array)[0] as String;
        var minutes = (secondsRemaining / 60).toNumber();
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

        // Page dots (vertical, right side)
        var dotRadius = 5;
        var dotSpacing = 16;
        var totalHeight = (teaTypes.size() - 1) * dotSpacing;
        var dotX = dc.getWidth() - 25;
        var startY = dc.getHeight() / 2 - totalHeight / 2;

        for (var i = 0; i < teaTypes.size(); i++) {
            var dotY = startY + i * dotSpacing;
            if (i == currentTeaIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.fillCircle(dotX, dotY, dotRadius);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                dc.fillCircle(dotX, dotY, dotRadius);
            }
        }
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
