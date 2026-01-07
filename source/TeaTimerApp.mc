using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.Attention;
using Toybox.Lang;

var timerView;

class TeaTimer {
    var name;
    var durationSeconds;
    var color;

    function initialize(name, durationSeconds, color) {
        self.name = name;
        self.durationSeconds = durationSeconds;
        self.color = color;
    }

    function getElapsedSeconds(secondsRemaining) {
        return durationSeconds - secondsRemaining;
    }

    function getProgress(secondsRemaining) {
        var elapsedSeconds = getElapsedSeconds(secondsRemaining);
        return elapsedSeconds.toFloat() / durationSeconds.toFloat();
    }

    function formatTimeRemaining(secondsRemaining) {
        var minutes = (secondsRemaining / 60).toNumber();
        var seconds = secondsRemaining % 60;
        return minutes + ":" + seconds.format("%02d");
    }

    function isComplete(secondsRemaining) {
        return secondsRemaining == 0;
    }
}

var teaTypes = [
    new TeaTimer("Earl Grey", 240, Graphics.COLOR_ORANGE),  // 4 minutes
    new TeaTimer("Jasmine", 150, Graphics.COLOR_YELLOW),    // 2.5 minutes
    new TeaTimer("Green", 120, Graphics.COLOR_GREEN),       // 2 minutes
    new TeaTimer("Mint", 360, Graphics.COLOR_BLUE)          // 6 minutes
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
        secondsRemaining = teaTypes[currentTeaIndex].durationSeconds;
        timer = new Timer.Timer();
    }

    function startTimer() {
        isRunning = true;
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
        var currentTea = teaTypes[currentTeaIndex];

        if (secondsRemaining > 0) {
            secondsRemaining -= 1;
            if (currentTea.isComplete(secondsRemaining)) {
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
        secondsRemaining = teaTypes[currentTeaIndex].durationSeconds;
        isRunning = false;
        timer.stop();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawProgressArc(dc);
        drawTeaName(dc);
        drawTimer(dc);
        drawPageDots(dc);
    }

    function formatTimeString() {
        var currentTea = teaTypes[currentTeaIndex];
        return currentTea.formatTimeRemaining(secondsRemaining);
    }

    function drawProgressArc(dc) {
        var currentTea = teaTypes[currentTeaIndex];
        var elapsedSeconds = currentTea.getElapsedSeconds(secondsRemaining);

        // Only draw progress if timer has started
        if (elapsedSeconds > 0) {
            var centerX = dc.getWidth() / 2;
            var centerY = dc.getHeight() / 2;
            var radius = (dc.getWidth() / 2) - 10;

            // Calculate arc angle (0 = top, clockwise)
            var progress = currentTea.getProgress(secondsRemaining);
            var arcAngle = (progress * 360).toNumber();

            dc.setColor(currentTea.color, Graphics.COLOR_BLACK);
            dc.setPenWidth(6);
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90 - arcAngle);
        }
    }

    function drawTeaName(dc) {
        var currentTea = teaTypes[currentTeaIndex];

        dc.setColor(currentTea.color, Graphics.COLOR_BLACK);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - 40,
            Graphics.FONT_MEDIUM,
            currentTea.name,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawTimer(dc) {
        var timeString = formatTimeString();
        var currentTea = teaTypes[currentTeaIndex];

        dc.setColor(currentTea.color, Graphics.COLOR_BLACK);
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
            var tea = teaTypes[i];

            if (i == currentTeaIndex) {
                dc.setColor(tea.color, Graphics.COLOR_BLACK);
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
        var currentTea = teaTypes[currentTeaIndex];

        if (currentTea.isComplete(timerView.secondsRemaining)) {
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
