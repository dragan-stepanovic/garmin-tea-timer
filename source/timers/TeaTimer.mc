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

        secondsRemaining = decrease(secondsRemaining);

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

    function decrease(seconds) {
        return seconds - 1;
    }

    function alreadyCompleted() {
        return secondsRemaining == 0;
    }

    function onReadyOrComplete(onReady, onComplete) {
        if (isReady()) {
            onReady.invoke();
            return;
        } 
        
        if (isComplete()) {
            onComplete.invoke();
            return;
        }
    }

    function isComplete() {
        return secondsRemaining == 0;
    }

    function isReady() {
        return elapsedSeconds() == 0;
    }
}
