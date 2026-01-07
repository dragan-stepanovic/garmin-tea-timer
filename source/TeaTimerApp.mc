using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Lang;

var timerView;

class TeaTimerApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        timerView = new TeaTimerView();
        return [timerView, new TeaTimerDelegate()];
    }
}
