package noise;

import flash.geom.Rectangle;
import flash.display.BitmapData;

class Exporter {
    static inline var WIDTH = 16384;
    static inline var HEIGHT = 16384;

    static inline var PIXELS_AT_ONCE = 1024;

    static var noise:BitmapData;
    static var x = 0;
    static var y = 0;
    static var rect = new Rectangle();

    static function main() {
        noise = new flash.display.BitmapData(WIDTH, HEIGHT);
        noise.noise(3, 0, 255, 7);

        flash.Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, exportNoise);
    }

    static function exportNoise(event:flash.events.Event) {
        var startTime = flash.Lib.getTimer();
        var endTime = startTime + 950/flash.Lib.current.stage.frameRate;

        var timeOut = flash.Lib.getTimer() >= endTime;
        while (!timeOut && y < noise.height) {
            while (!timeOut && x < noise.width) {
                var targetX = x + PIXELS_AT_ONCE;

                if (targetX > noise.width) {
                    targetX = noise.width;
                }

                rect.x = x;
                rect.y = y;
                rect.width = targetX - x;
                rect.height = 1;

                var pixels = noise.getVector(rect);

                flash.Lib.trace(pixels.join("\n"));

                x = targetX;

                timeOut = flash.Lib.getTimer() >= endTime;
            }

            if (!timeOut) {
                x = 0;
                ++y;
            }
        }

        var progress = (y * noise.width + x) / (noise.width * noise.height);

        var g = flash.Lib.current.graphics;
        g.clear();
        g.beginFill(if (progress >= 1) 0x00ff00 else 0x000000);
        g.drawRect(0, 0, flash.Lib.current.stage.stageWidth * progress, flash.Lib.current.stage.stageHeight);
        g.endFill();
    }
}
