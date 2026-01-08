using Toybox.Lang;

class TeaTimer {
    var name;
    var durationInSeconds;
    var color;
    var timeRemaining;

    function initialize(name, durationInSeconds, color) {
        self.name = name;
        self.durationInSeconds = durationInSeconds;
        self.color = color;
        self.timeRemaining = new TimeRemaining(durationInSeconds);
    }

    function reset(onReset) {
        timeRemaining.resetTo(durationInSeconds);
        onReset.invoke();
    }

    function advance(onAdvanced, onComplete) {
        if (alreadyCompleted()) {
            return;
        }

        timeRemaining.decrease();
        onAdvanced.invoke();

        if (isComplete()) {
            onComplete.invoke();
        }
    }

    function ifReadyOrComplete(onReady, onComplete) {
        if (isReady()) {
            onReady.invoke();
            return;
        }

        if (isComplete()) {
            onComplete.invoke();
            return;
        }
    }

    function ifNotRunning(doThis) {
        if (isNotRunning()) {
            doThis.invoke();
        }
    }

    function minutesAndSecondsLeft() {
        return timeRemaining.minutesAndSecondsLeft();
    }

    function completionRatio() {
        return elapsedSeconds().toFloat() / durationInSeconds.toFloat();
    }

    function elapsedSeconds() {
        return durationInSeconds - timeRemaining.asInt();
    }

    function isReady() {
        return elapsedSeconds() == 0;
    }

    function isComplete() {
        return timeRemaining.isZero();
    }

    function isNotRunning() {
        return isReady() || isComplete();
    }

    function alreadyCompleted() {
        return timeRemaining.isZero();
    }
}
