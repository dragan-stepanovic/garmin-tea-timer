using Toybox.Lang;

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

    function reset(onReset) {
        secondsRemaining = durationSeconds;
        onReset.invoke();
    }

    function advance(onComplete) {
        if (alreadyCompleted()) {
            return;
        }

        secondsRemaining = secondsRemaining - 1;

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
        var minutes = (secondsRemaining / 60).toNumber();
        var seconds = secondsRemaining % 60;
        return [minutes, seconds];
    }

    function elapsedSeconds() {
        return durationSeconds - secondsRemaining;
    }

    function completionRatio() {
        return elapsedSeconds().toFloat() / durationSeconds.toFloat();
    }

    function isReady() {
        return elapsedSeconds() == 0;
    }

    function isComplete() {
        return secondsRemaining == 0;
    }

    function isNotRunning() {
        return isReady() || isComplete();
    }

    function alreadyCompleted() {
        return secondsRemaining == 0;
    }
}
