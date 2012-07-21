package noise;

import flash.events.Event;
import flash.display.MovieClip;
import haxe.PosInfos;

class Main {
    static var tests = [test1];

    static var i = 0;

    public static function main() {
        haxe.Log.trace = trace;

        flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    static function trace(v:Dynamic, ?pos:PosInfos) {
        flash.Lib.trace(pos.fileName + ":" + pos.lineNumber + ": " + v);
    }

    static function onEnterFrame(e:Event) {
        if (i >= tests.length) {
            trace("All tests complete");
            flash.Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        } else {
            trace("Test " + (i+1));
            tests[i]();
            ++i;
        }
    }

    static function test1() {
    }
}
