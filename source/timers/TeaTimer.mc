using Toybox.Lang;

class TeaTimer {
    var name;
    var durationSeconds;
    var color;
    var timeRemaining;

    function initialize(name, durationSeconds, color) {
        self.name = name;
        self.durationSeconds = durationSeconds;
        self.color = color;
        self.timeRemaining = new TimeRemaining(durationSeconds);
    }

    function reset(onReset) {
        timeRemaining.reset(durationSeconds);
        onReset.invoke();
    }

    function advance(onUpdated, onComplete) {
        if (alreadyCompleted()) {
            return;
        }

        timeRemaining.decrease();
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

    function completionRatio() {
        return elapsedSeconds().toFloat() / durationSeconds.toFloat();
    }

    function elapsedSeconds() {
        return durationSeconds - timeRemaining.asInt();
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
