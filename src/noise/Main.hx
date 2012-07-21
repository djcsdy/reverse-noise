package noise;

import flash.display.BitmapData;
import flash.events.Event;
import flash.display.MovieClip;
import haxe.PosInfos;

class Main {
    static var tests = [test1, test2, test3, test4];

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

    static function test4() {
        var bitmap1 = new BitmapData(2, 1);
        var bitmap2 = new BitmapData(bitmap1.width, bitmap1.height);
        var bitmap3 = new BitmapData(bitmap1.width, bitmap1.height);
        var bitmap4 = new BitmapData(bitmap1.width, bitmap1.height);

        bitmap1.noise(4, 0, 255, 15);
        bitmap2.noise(4, 0, 255, 7);
        bitmap3.noise(4, 0, 255, 3);
        bitmap4.noise(4, 0, 255, 1);

        var v11 = Std.int(bitmap1.getPixel32(0, 0));
        var v12 = Std.int(bitmap1.getPixel32(1, 0));
        var v21 = Std.int(bitmap2.getPixel32(0, 0));
        var v22 = Std.int(bitmap2.getPixel32(1, 0));
        var v31 = Std.int(bitmap3.getPixel32(0, 0));
        var v32 = Std.int(bitmap3.getPixel32(1, 0));
        var v41 = Std.int(bitmap4.getPixel32(0, 0));
        var v42 = Std.int(bitmap4.getPixel32(1, 0));

        var b1 = v11 >> 16 & 0xff;
        var b2 = v11 >> 8 & 0xff;
        var b3 = v11 & 0xff;
        var b4 = v11 >> 24 & 0xff;
        var b5 = v12 >> 16 & 0xff;
        var b6 = v12 >> 8 & 0xff;

        for (v in [v11, v12, v21, v22, v31, v32, v41, v42]) {
            trace(StringTools.hex(v, 8));
        }

        for (b in [b1,b2,b3,b4,b5,b6]) {
            trace(StringTools.hex(b, 2));
        }

        if (v21 >> 16 & 0xff == b1
                && v21 >> 8 & 0xff == b2
                && v21 & 0xff == b3
                && v22 >> 16 & 0xff == b4
                && v22 >> 8 & 0xff == b5
                && v22 & 0xff == b6
                && v31 >> 16 & 0xff == b1
                && v31 >> 8 & 0xff == b2
                && v32 >> 16 & 0xff == b3
                && v32 >> 8 & 0xff == b4
                && v41 >> 16 & 0xff == b1
                && v42 >> 16 & 0xff == b2) {
            trace("Noise bytes are fetched as required in the order R, G, B, A");
        } else {
            trace("Noise bytes are NOT fetched in the order R, G, B, A");
        }
    }
}
