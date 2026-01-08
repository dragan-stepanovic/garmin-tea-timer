using Toybox.Lang;

class TimeRemaining {
    var secondsRemaining;

    function initialize(seconds) {
        self.secondsRemaining = seconds;
    }

    function minutesAndSecondsLeft() {
        return [minutesLeft(), secondsLeft()];
    }

    function decrease() {
        secondsRemaining = secondsRemaining - 1;
    }

    function reset(durationSeconds) {
        secondsRemaining = durationSeconds;
    }

    function isZero() {
        return secondsRemaining == 0;
    }

    function asInt() {
        return secondsRemaining;
    }

    function minutesLeft() {
        return (secondsRemaining / 60).toNumber();
    }

    function secondsLeft() {
        return secondsRemaining % 60;
    }
}
