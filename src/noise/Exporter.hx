package noise;

import flash.geom.Rectangle;
import flash.events.Event;
import flash.display.BitmapData;
class Exporter {
    static var noise:BitmapData;
    static var noiseY:Int;

    static function main() {
        noise = new BitmapData(16384, 16384);
        noise.noise(3, 0, 255, 15);

        flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, exportNoise);
    }

    static function exportNoise(event:Event) {
        var rect = new Rectangle(0, noiseY++, noise.width, 1);
        trace(noise.getVector(rect).join(","));

        if (noiseY >= noise.height) {
            flash.Lib.current.stage.removeEventListener(Event.ENTER_FRAME, exportNoise);
        }
    }
}
