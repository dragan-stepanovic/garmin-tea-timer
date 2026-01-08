using Toybox.Lang;

class TimeRemaining {
    var secondsRemaining;

    function initialize(seconds) {
        self.secondsRemaining = seconds;
    }

    function decrease() {
        secondsRemaining = secondsRemaining - 1;
    }

    function reset(durationSeconds) {
        secondsRemaining = durationSeconds;
    }

    function minutesLeft() {
        return (secondsRemaining / 60).toNumber();
    }

    function secondsLeft() {
        return secondsRemaining % 60;
    }

    function minutesAndSecondsLeft() {
        return [minutesLeft(), secondsLeft()];
    }

    function isZero() {
        return secondsRemaining == 0;
    }

    function asInt() {
        return secondsRemaining;
    }
}
