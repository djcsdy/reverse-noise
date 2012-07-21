package noise;

import flash.display.BitmapData;
import flash.events.Event;
import flash.display.MovieClip;
import haxe.PosInfos;

class Main {
    static var tests = [test1, test2];

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
        var size = 1024;

        var horizontal = new BitmapData(size, 1);
        var vertical = new BitmapData(1, size);

        horizontal.noise(1);
        vertical.noise(1);

        for (i in 0...size) {
            if (horizontal.getPixel(i, 1) != vertical.getPixel(1, i)) {
                trace("Noise does NOT wrap");
                return;
            }
        }

        trace("Noise wraps");
    }

    static function test2() {
        var bitmap1 = new BitmapData(256, 1024);
        var bitmap2 = new BitmapData(512, 512);

        bitmap1.noise(2);
        bitmap2.noise(2);

        for (i in 0...(bitmap1.width*bitmap1.height)) {
            var x1 = i % bitmap1.width;
            var y1 = Std.int(i / bitmap1.width);

            var x2 = i % bitmap2.width;
            var y2 = Std.int(i / bitmap2.width);

            if (bitmap1.getPixel(x1, y1) != bitmap2.getPixel(x2, y2)) {
                trace("Noise does NOT wrap");
                return;
            }
        }

        trace("Noise wraps");
    }
}
