package noise;

import flash.display.BitmapDataChannel;
import haxe.unit.TestRunner;
import flash.display.BitmapData;
import haxe.unit.TestCase;

class NoiseTest extends TestCase {
    static function main() {
#if flash
        var oldPrint = TestRunner.print;
        TestRunner.print = function(value) {
            oldPrint(value);
            flash.Lib.trace(value);
        }
#end

        var testRunner = new TestRunner();
        testRunner.add(new NoiseTest());
        testRunner.run();
    }

    public function new() {
        super();
    }

    public function testNoiseWrapsLeftToRightTopToBottom() {
        var bitmap1 = new BitmapData(256, 1024);
        var bitmap2 = new BitmapData(512, 512);

        bitmap1.noise(2);
        bitmap2.noise(2);

        for (i in 0...(bitmap1.width*bitmap1.height)) {
            var x1 = i % bitmap1.width;
            var y1 = Std.int(i / bitmap1.width);

            var x2 = i % bitmap2.width;
            var y2 = Std.int(i / bitmap2.width);

            assertEquals(bitmap1.getPixel(x1, y1), bitmap2.getPixel(x2, y2));
        }
    }

    public function testNoiseGeneratorFetchesRandomBytesOnlyForUnmaskedChannelsInTheOrderRGBA() {
        var tmpBitmap = new BitmapData(1, 1);

        var bitmaps = [];
        var numEnabledChannels = [1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4];

        for (i in 0...15) {
            var bitmap = new BitmapData(256, 256);
            bitmaps.push(bitmap);
            var channelOptions = i + 1;
            bitmap.noise(4, 0, 255, channelOptions);
        }

        for (byteIndex in 0...(bitmaps[0].width * bitmaps[0].height)) {
            var x1 = byteIndex % bitmaps[0].width;
            var y1 = Std.int(byteIndex / bitmaps[0].width);

            var expectedByte = bitmaps[0].getPixel(x1, y1) >> 16 & 0xff;

            for (bitmapIndex in 1...bitmaps.length) {
                var bitmap = bitmaps[bitmapIndex];
                var channelOptions = bitmapIndex + 1;

                var x2 = Std.int(byteIndex / numEnabledChannels[bitmapIndex]) % bitmap.width;
                var y2 = Std.int(Std.int(byteIndex/numEnabledChannels[bitmapIndex]) / bitmap.width);

                var channel = byteIndex % numEnabledChannels[bitmapIndex];

                for (i in 0...4) {
                    if (channel >= i
                            && channelOptions & (1 << i) == 0) {
                        ++channel;
                    }
                }

                var pixel = bitmap.getPixel32(x2, y2);
                var alpha = pixel >> 24 & 0xff;

                if (channel == 3) {
                    assertEquals(expectedByte, alpha);
                } else {
                    var colour = pixel >> ((2-channel) * 8) & 0xff;

                    if (alpha == 255) {
                        assertEquals(expectedByte, colour);
                    } else {
                        // Compensate for loss caused alpha pre-multiplication.
                        tmpBitmap.setPixel32(0, 0, alpha << 24 | expectedByte);
                        var expectedLossyByte = tmpBitmap.getPixel(0, 0);
                        assertEquals(expectedLossyByte, colour);
                    }
                }
            }
        }
    }
}
