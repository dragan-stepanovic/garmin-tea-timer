using Toybox.WatchUi;

class TeaTimerDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        timerView.onSelect();
        return true;
    }

    function onNextPage() {
        timerView.onNextPage();
        return true;
    }

    function onPreviousPage() {
        timerView.onPreviousPage();
        return true;
    }
}
