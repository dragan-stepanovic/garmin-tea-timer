using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.Attention;
using Toybox.Lang;

class TeaTimerView extends WatchUi.View {
    var timer;
    var isRunning = false;
    var currentTeaTimer;
    var teaTypes;
    var currentTeaTimerIndex = 0;

    function initialize() {
        View.initialize();
        timer = new Timer.Timer();
        teaTypes = TeaTimers.all();
        currentTeaTimer = teaTypes[currentTeaTimerIndex];
    }

    function startTimer() {
        isRunning = true;
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
        currentTeaTimer.tick(method(:onTimerComplete));
        WatchUi.requestUpdate();
    }

    function onTimerComplete() as Void {
        isRunning = false;
        Attention.vibrate([
            new Attention.VibeProfile(100, 500),
            new Attention.VibeProfile(0, 300),
            new Attention.VibeProfile(100, 500),
            new Attention.VibeProfile(0, 300),
            new Attention.VibeProfile(100, 500)
        ]);
    }

    function reset() {
        currentTeaTimer.reset();
        isRunning = false;
        timer.stop();
        WatchUi.requestUpdate();
    }

    function onSelect() {
        if (currentTeaTimer.isComplete()) {
            reset();
        } else if (!isRunning) {
            startTimer();
        }
    }

    function onNextPage() {
        if (!isRunning) {
            currentTeaTimerIndex = (currentTeaTimerIndex + 1) % teaTypes.size();
            currentTeaTimer = teaTypes[currentTeaTimerIndex];
            reset();
        }
    }

    function onPreviousPage() {
        if (!isRunning) {
            currentTeaTimerIndex = (currentTeaTimerIndex - 1 + teaTypes.size()) % teaTypes.size();
            currentTeaTimer = teaTypes[currentTeaTimerIndex];
            reset();
        }
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawProgressArc(dc);
        drawTeaIcon(dc);
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
            dc.getHeight() / 2 - 106,
            Graphics.FONT_SMALL,
            currentTeaTimer.name,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawTimer(dc) {
        var timeString = formatTimeString();

        dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_NUMBER_HOT,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawTeaIcon(dc) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2 - 165;

        if (currentTeaTimerIndex == 0) {
            // Jasmine
            drawJasmineFlower(dc, centerX, centerY);
        } else if (currentTeaTimerIndex == 1) {
            // Mint
            drawMintLeaves(dc, centerX, centerY);
        } else if (currentTeaTimerIndex == 2) {
            // Earl Grey
            drawSteamLines(dc, centerX, centerY);
        } else if (currentTeaTimerIndex == 3) {
            // Green Tea
            drawTeaLeaf(dc, centerX, centerY);
        }
    }

    function drawJasmineFlower(dc, centerX, centerY) {
        var petalRadius = 6;
        var centerDistance = 12;

        dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);

        // Draw 5 petals in a circle pattern
        for (var i = 0; i < 5; i++) {
            var angle = (i * 72) - 90; // 360/5 = 72 degrees, start at top
            var angleRad = angle * Math.PI / 180.0;
            var petalX = centerX + (centerDistance * Math.cos(angleRad)).toNumber();
            var petalY = centerY + (centerDistance * Math.sin(angleRad)).toNumber();
            dc.fillCircle(petalX, petalY, petalRadius);
        }

        // Center of flower (white)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.fillCircle(centerX, centerY, 4);
    }

    function drawMintLeaves(dc, centerX, centerY) {
        dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
        dc.setPenWidth(3);

        // Center stem
        dc.drawLine(centerX, centerY - 15, centerX, centerY + 15);

        // Left leaf (upper)
        dc.drawLine(centerX, centerY - 8, centerX - 10, centerY - 12);
        dc.drawLine(centerX - 10, centerY - 12, centerX - 12, centerY - 8);

        // Right leaf (upper)
        dc.drawLine(centerX, centerY - 8, centerX + 10, centerY - 12);
        dc.drawLine(centerX + 10, centerY - 12, centerX + 12, centerY - 8);

        // Left leaf (middle)
        dc.drawLine(centerX, centerY, centerX - 12, centerY - 2);
        dc.drawLine(centerX - 12, centerY - 2, centerX - 14, centerY + 2);

        // Right leaf (middle)
        dc.drawLine(centerX, centerY, centerX + 12, centerY - 2);
        dc.drawLine(centerX + 12, centerY - 2, centerX + 14, centerY + 2);

        // Left leaf (lower)
        dc.drawLine(centerX, centerY + 8, centerX - 10, centerY + 5);
        dc.drawLine(centerX - 10, centerY + 5, centerX - 12, centerY + 9);

        // Right leaf (lower)
        dc.drawLine(centerX, centerY + 8, centerX + 10, centerY + 5);
        dc.drawLine(centerX + 10, centerY + 5, centerX + 12, centerY + 9);
    }

    function drawSteamLines(dc, centerX, centerY) {
        dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);

        // Three wavy steam lines
        // Left steam line
        dc.drawLine(centerX - 12, centerY + 10, centerX - 10, centerY + 5);
        dc.drawLine(centerX - 10, centerY + 5, centerX - 12, centerY);
        dc.drawLine(centerX - 12, centerY, centerX - 10, centerY - 5);
        dc.drawLine(centerX - 10, centerY - 5, centerX - 12, centerY - 10);

        // Center steam line
        dc.drawLine(centerX, centerY + 10, centerX + 2, centerY + 5);
        dc.drawLine(centerX + 2, centerY + 5, centerX, centerY);
        dc.drawLine(centerX, centerY, centerX + 2, centerY - 5);
        dc.drawLine(centerX + 2, centerY - 5, centerX, centerY - 10);

        // Right steam line
        dc.drawLine(centerX + 12, centerY + 10, centerX + 14, centerY + 5);
        dc.drawLine(centerX + 14, centerY + 5, centerX + 12, centerY);
        dc.drawLine(centerX + 12, centerY, centerX + 14, centerY - 5);
        dc.drawLine(centerX + 14, centerY - 5, centerX + 12, centerY - 10);
    }

    function drawTeaLeaf(dc, centerX, centerY) {
        dc.setColor(currentTeaTimer.color, Graphics.COLOR_BLACK);
        dc.setPenWidth(3);

        // Leaf outline - teardrop shape
        // Left side of leaf
        dc.drawLine(centerX, centerY - 15, centerX - 8, centerY - 5);
        dc.drawLine(centerX - 8, centerY - 5, centerX - 10, centerY + 5);
        dc.drawLine(centerX - 10, centerY + 5, centerX - 5, centerY + 12);

        // Right side of leaf
        dc.drawLine(centerX, centerY - 15, centerX + 8, centerY - 5);
        dc.drawLine(centerX + 8, centerY - 5, centerX + 10, centerY + 5);
        dc.drawLine(centerX + 10, centerY + 5, centerX + 5, centerY + 12);

        // Bottom point
        dc.drawLine(centerX - 5, centerY + 12, centerX, centerY + 15);
        dc.drawLine(centerX + 5, centerY + 12, centerX, centerY + 15);

        // Center vein
        dc.setPenWidth(2);
        dc.drawLine(centerX, centerY - 12, centerX, centerY + 10);
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
