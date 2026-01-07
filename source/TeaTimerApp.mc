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

    function completionRatio() {
        return elapsedSeconds().toFloat() / durationSeconds.toFloat();
    }

    function isComplete() {
        return secondsRemaining == 0;
    }

    function timeRemaining() {
        var minutes = (secondsRemaining / 60).toNumber();
        var seconds = secondsRemaining % 60;
        return [minutes, seconds];
    }
}

var teaTypes;
var currentTeaTimerIndex = 0;

class TeaTimerApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
        teaTypes = [
            new JasmineTimer(),
            new MintTeaTimer(),
            new EarlGreyTimer(),
            new GreenTeaTimer()
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
    var currentTeaTimer;

    function initialize() {
        View.initialize();
        timer = new Timer.Timer();
        currentTeaTimer = teaTypes[currentTeaTimerIndex];
    }

    function startTimer() {
        isRunning = true;
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
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
        currentTeaTimer.reset();
        isRunning = false;
        timer.stop();
        WatchUi.requestUpdate();
    }

    function onSelect() {
        if (currentTeaTimer.isComplete()) {
            restart();
        } else if (!isRunning) {
            startTimer();
        }
    }

    function onNextPage() {
        if (!isRunning) {
            currentTeaTimerIndex = (currentTeaTimerIndex + 1) % teaTypes.size();
            currentTeaTimer = teaTypes[currentTeaTimerIndex];
            restart();
        }
    }

    function onPreviousPage() {
        if (!isRunning) {
            currentTeaTimerIndex = (currentTeaTimerIndex - 1 + teaTypes.size()) % teaTypes.size();
            currentTeaTimer = teaTypes[currentTeaTimerIndex];
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
        var minutesAndSeconds = currentTeaTimer.timeRemaining();
        return minutesAndSeconds[0] + ":" + minutesAndSeconds[1].format("%02d");
    }

    function drawProgressArc(dc) {
        if (currentTeaTimer.elapsedSeconds() > 0) {
            var centerX = dc.getWidth() / 2;
            var centerY = dc.getHeight() / 2;
            var radius = (dc.getWidth() / 2) - 10;

            // Calculate arc angle (0 = top, clockwise)
            var arcAngle = (currentTeaTimer.completionRatio() * 360).toNumber();

            dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
            dc.setPenWidth(6);
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90 - arcAngle);
        }
    }

    function drawTeaName(dc) {
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
        var baseDotRadius = 5;
        var dotSpacing = 16;
        var totalHeight = (teaTypes.size() - 1) * dotSpacing;
        var dotX = dc.getWidth() - 25;
        var startY = dc.getHeight() / 2 - totalHeight / 2;

        for (var i = 0; i < teaTypes.size(); i++) {
            var dotY = startY + i * dotSpacing;
            var teaTimer = teaTypes[i];

            // Calculate proximity-based radius
            var distance = (i - currentTeaTimerIndex).abs();
            var radius = baseDotRadius;

            if (i == currentTeaTimerIndex) {
                radius = 7; // Largest for selected
                dc.setColor(teaTimer.color, Graphics.COLOR_BLACK);
            } else if (distance == 1) {
                radius = 5; // Medium for adjacent
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            } else {
                radius = 3; // Smallest for distant
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            }

            dc.fillCircle(dotX, dotY, radius);
        }
    }
}
