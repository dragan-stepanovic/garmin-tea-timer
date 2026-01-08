using Toybox.Lang;

class TeaTimer {
    var name;
    var durationSeconds;
    var color;
    var time;

    function initialize(name, durationSeconds, color) {
        self.name = name;
        self.durationSeconds = durationSeconds;
        self.color = color;
        self.time = new TimeRemaining(durationSeconds);
    }

    function reset(onReset) {
        time.reset(durationSeconds);
        onReset.invoke();
    }

    function advance(onUpdated, onComplete) {
        if (alreadyCompleted()) {
            return;
        }

        time.decrease();
        onUpdated.invoke();

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

    function timeRemaining() {
        return [time.minutesLeft(), time.secondsLeft()];
    }

    function minutesLeft() {
        return time.minutesLeft();
    }

    function secondsLeft() {
        return time.secondsLeft();
    }

    function completionRatio() {
        return elapsedSeconds().toFloat() / durationSeconds.toFloat();
    }

    function elapsedSeconds() {
        return durationSeconds - time.value();
    }

    function isReady() {
        return elapsedSeconds() == 0;
    }

    function isComplete() {
        return time.isZero();
    }

    function isNotRunning() {
        return isReady() || isComplete();
    }

    function alreadyCompleted() {
        return time.isZero();
    }
}
