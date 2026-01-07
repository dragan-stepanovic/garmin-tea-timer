using Toybox.Lang;

class TeaTimers {
    static function all() {
        return [
            new JasmineTimer(),
            new MintTeaTimer(),
            new EarlGreyTimer(),
            new GreenTeaTimer()
        ];
    }
}
