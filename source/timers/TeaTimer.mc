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

    function reset() {
        secondsRemaining = durationSeconds;
    }

    function tick(onComplete) {
        if (alreadyCompleted()) {
            return;
        }

        secondsRemaining = secondsRemaining - 1;

        if (isComplete()) {
            onComplete.invoke();
        }
    }

    function elapsedSeconds() {
        return durationSeconds - secondsRemaining;
    }

    function completionRatio() {
        return elapsedSeconds().toFloat() / durationSeconds.toFloat();
    }

    function timeRemaining() {
        var minutes = (secondsRemaining / 60).toNumber();
        var seconds = secondsRemaining % 60;
        return [minutes, seconds];
    }

    function alreadyCompleted() {
        return secondsRemaining == 0;
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

    function isReady() {
        return elapsedSeconds() == 0;
    }

    function isComplete() {
        return secondsRemaining == 0;
    }

    function isNotRunning() {
        return isReady() || isComplete();
    }

    function ifNotRunning(onNotRunning) {
        if (isNotRunning()) {
            onNotRunning.invoke();
        }
    }
}
