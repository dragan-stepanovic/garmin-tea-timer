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
    var secondsRemaining;

    function initialize(name, durationSeconds, color) {
        self.name = name;
        self.durationSeconds = durationSeconds;
        self.color = color;
        self.secondsRemaining = durationSeconds;
    }

    function reset() {
        secondsRemaining = durationSeconds;
    }

    function tick() {
        if (secondsRemaining > 0) {
            secondsRemaining -= 1;
        }
    }

    function elapsedSeconds() {
        return durationSeconds - secondsRemaining;
    }

    function progress() {
        return elapsedSeconds().toFloat() / durationSeconds.toFloat();
    }

    function formatTimeRemaining() {
        var minutes = (secondsRemaining / 60).toNumber();
        var seconds = secondsRemaining % 60;
        return minutes + ":" + seconds.format("%02d");
    }

    function isComplete() {
        return secondsRemaining == 0;
    }
}

class EarlGreyTimer extends TeaTimer {
    function initialize() {
        TeaTimer.initialize("Earl Grey", 240, Graphics.COLOR_ORANGE);
    }
}

class JasmineTimer extends TeaTimer {
    function initialize() {
        TeaTimer.initialize("Jasmine", 150, Graphics.COLOR_YELLOW);
    }
}

class GreenTeaTimer extends TeaTimer {
    function initialize() {
        TeaTimer.initialize("Green", 120, Graphics.COLOR_GREEN);
    }
}

class MintTeaTimer extends TeaTimer {
    function initialize() {
        TeaTimer.initialize("Mint", 360, Graphics.COLOR_BLUE);
    }
}

var teaTypes;
var currentTeaTimerIndex = 0;

class TeaTimerApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
        teaTypes = [
            new EarlGreyTimer(),
            new JasmineTimer(),
            new GreenTeaTimer(),
            new MintTeaTimer()
        ];
    }

    function getInitialView() {
        timerView = new TeaTimerView();
        return [timerView, new TeaTimerDelegate()];
    }
}

class TeaTimerView extends WatchUi.View {
    var timer;
    var isRunning = false;

    function initialize() {
        View.initialize();
        timer = new Timer.Timer();
    }

    function startTimer() {
        isRunning = true;
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
        var currentTeaTimer = teaTypes[currentTeaTimerIndex];

        currentTeaTimer.tick();
        if (currentTeaTimer.isComplete()) {
            isRunning = false;
            Attention.vibrate([
                new Attention.VibeProfile(100, 500),
                new Attention.VibeProfile(0, 300),
                new Attention.VibeProfile(100, 500),
                new Attention.VibeProfile(0, 300),
                new Attention.VibeProfile(100, 500)
            ]);
        }
        WatchUi.requestUpdate();
    }

    function restart() {
        teaTypes[currentTeaTimerIndex].reset();
        isRunning = false;
        timer.stop();
        WatchUi.requestUpdate();
    }

    function handleSelect() {
        var currentTeaTimer = teaTypes[currentTeaTimerIndex];

        if (currentTeaTimer.isComplete()) {
            restart();
        } else if (!isRunning) {
            startTimer();
        }
    }

    function handleNextPage() {
        if (!isRunning) {
            currentTeaTimerIndex = (currentTeaTimerIndex + 1) % teaTypes.size();
            restart();
        }
    }

    function handlePreviousPage() {
        if (!isRunning) {
            currentTeaTimerIndex = (currentTeaTimerIndex - 1 + teaTypes.size()) % teaTypes.size();
            restart();
        }
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
        var currentTeaTimer = teaTypes[currentTeaTimerIndex];
        return currentTeaTimer.formatTimeRemaining();
    }

    function drawProgressArc(dc) {
        var currentTeaTimer = teaTypes[currentTeaTimerIndex];

        // Only draw progress if timer has started
        if (currentTeaTimer.elapsedSeconds() > 0) {
            var centerX = dc.getWidth() / 2;
            var centerY = dc.getHeight() / 2;
            var radius = (dc.getWidth() / 2) - 10;

            // Calculate arc angle (0 = top, clockwise)
            var progressValue = currentTeaTimer.progress();
            var arcAngle = (progressValue * 360).toNumber();

            dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
            dc.setPenWidth(6);
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90 - arcAngle);
        }
    }

    function drawTeaName(dc) {
        var currentTeaTimer = teaTypes[currentTeaTimerIndex];

        dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - 40,
            Graphics.FONT_MEDIUM,
            currentTeaTimer.name,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawTimer(dc) {
        var timeString = formatTimeString();
        var currentTeaTimer = teaTypes[currentTeaTimerIndex];

        dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
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
            var teaTimer = teaTypes[i];

            if (i == currentTeaTimerIndex) {
                dc.setColor(teaTimer.color, Graphics.COLOR_BLACK);
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
        timerView.handleSelect();
        return true;
    }

    function onNextPage() {
        timerView.handleNextPage();
        return true;
    }

    function onPreviousPage() {
        timerView.handlePreviousPage();
        return true;
    }
}
