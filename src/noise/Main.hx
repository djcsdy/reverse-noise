package noise;

import flash.display.BitmapData;
import flash.events.Event;
import flash.display.MovieClip;
import haxe.PosInfos;

class Main {
    static var tests = [test1, test2, test3];

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

    static function test3() {
        var bitmap1 = new BitmapData(256, 256);
        var bitmap2 = new BitmapData(bitmap1.width, bitmap1.height);
        var bitmap3 = new BitmapData(bitmap1.width, bitmap1.height);
        var bitmap4 = new BitmapData(bitmap1.width, bitmap1.height);

        bitmap1.noise(3, 0, 255, 15);
        bitmap2.noise(3, 0, 255, 7);
        bitmap3.noise(3, 0, 255, 3);
        bitmap4.noise(3, 0, 255, 1);

        for (y in 0...bitmap1.height) {
            for (x in 0...bitmap1.width) {
                var v1 = Std.int(bitmap1.getPixel32(x, y));
                var v2 = Std.int(bitmap2.getPixel(x, y));
                var v3 = Std.int(bitmap3.getPixel(x, y));
                var v4 = Std.int(bitmap4.getPixel(x, y));

                if (v2 != v1 & 0xffffff
                        || v3 != v1 & 0xffff00
                        || v4 != v1 & 0xff0000) {
                    trace("Noise channels flag does NOT simply mask ARGB noise");
                    return;
                }
            }
        }

        trace("Noise channels flag simply masks ARGB noise");
    }
}
