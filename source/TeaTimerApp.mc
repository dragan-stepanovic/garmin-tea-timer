using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.Attention;
using Toybox.Lang;

var timerView;

// Tea types: [name, seconds, color]
var teaTypes = [
    ["Earl Grey", 240, Graphics.COLOR_ORANGE],     // 4 minutes - orange/brown for black tea
    ["Jasmine", 150, Graphics.COLOR_YELLOW],       // 2.5 minutes - yellow for jasmine
    ["Green", 120, Graphics.COLOR_GREEN],          // 2 minutes - green
    ["Mint", 360, Graphics.COLOR_BLUE]             // 6 minutes - blue/mint
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
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawTeaName(dc);
        drawTimer(dc);
        drawPageDots(dc);
    }

    function formatTimeString() {
        var minutes = (secondsRemaining / 60).toNumber();
        var seconds = secondsRemaining % 60;
        return minutes + ":" + seconds.format("%02d");
    }

    function drawTeaName(dc) {
        var teaName = teaTypes[currentTeaIndex][0];
        var teaColor = teaTypes[currentTeaIndex][2];

        dc.setColor(teaColor, Graphics.COLOR_BLACK);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - 40,
            Graphics.FONT_MEDIUM,
            teaName,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawTimer(dc) {
        var timeString = formatTimeString();
        var teaColor = teaTypes[currentTeaIndex][2];

        dc.setColor(teaColor, Graphics.COLOR_BLACK);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 + 20,
            Graphics.FONT_LARGE,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawPageDots(dc) {
        var dotRadius = 5;
        var dotSpacing = 16;
        var totalHeight = (teaTypes.size() - 1) * dotSpacing;
        var dotX = dc.getWidth() - 25;
        var startY = dc.getHeight() / 2 - totalHeight / 2;

        for (var i = 0; i < teaTypes.size(); i++) {
            var dotY = startY + i * dotSpacing;
            var dotColor = teaTypes[i][2];

            if (i == currentTeaIndex) {
                dc.setColor(dotColor, Graphics.COLOR_BLACK);
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
