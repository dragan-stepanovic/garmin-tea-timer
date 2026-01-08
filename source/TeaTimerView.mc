using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.Attention;
using Toybox.Lang;

class TeaTimerView extends WatchUi.View {
    var garminTimer;
    var currentTeaTimer;
    var teaTypes;
    var currentTeaTimerIndex = 0;
    var drawer;

    function initialize() {
        View.initialize();
        garminTimer = new Timer.Timer();
        teaTypes = TeaTimers.all();
        currentTeaTimer = teaTypes[currentTeaTimerIndex];
        drawer = new TeaTimerDrawer();
    }

    function onSelect() {
        currentTeaTimer.ifReadyOrComplete(method(:startTimer), method(:reset));
    }

    function onNextPage() {
        currentTeaTimer.ifNotRunning(method(:switchToNextTeaType));
    }

    function onPreviousPage() {
        currentTeaTimer.ifNotRunning(method(:switchToPreviousTeaType));
    }

    function onUpdate(dc) {
        drawer.draw(dc, currentTeaTimer, currentTeaTimerIndex, teaTypes);
    }

    function startTimer() {
        garminTimer.start(method(:onTick), 1000, true);
    }

    function reset() {
        currentTeaTimer.reset(method(:onTimerReset));
    }

    function onTimerReset() {
        garminTimer.stop();
        WatchUi.requestUpdate();
    }

    function switchToNextTeaType() {
        currentTeaTimerIndex = (currentTeaTimerIndex + 1) % teaTypes.size();
        currentTeaTimer = teaTypes[currentTeaTimerIndex];
        reset();
    }

    function switchToPreviousTeaType() {
        currentTeaTimerIndex = (currentTeaTimerIndex - 1 + teaTypes.size()) % teaTypes.size();
        currentTeaTimer = teaTypes[currentTeaTimerIndex];
        reset();
    }

    function onTick() as Void {
        currentTeaTimer.advance(method(:onTimerUpdated), method(:onTimerComplete));
    }

    function onTimerUpdated() as Void {
        WatchUi.requestUpdate();
    }

    function onTimerComplete() as Void {
        vibrate();
    }

    function vibrate() {
        Attention.vibrate([
            new Attention.VibeProfile(100, 500),
            new Attention.VibeProfile(0, 300),
            new Attention.VibeProfile(100, 500),
            new Attention.VibeProfile(0, 300),
            new Attention.VibeProfile(100, 500)
        ]);
    }
}
