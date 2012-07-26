package reverse_noise;

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

    /** Proves that noise generated with a seed of zero will be identical to noise generated with a seed of one
     * (all other parameters being equal).
     *
     * The reason for this is that zero is not a useful seed for the Lehmer pseudo-random number generator that
     * Flash uses to generate noise. If seeded with zero, the PRNG just generates an endless stream of zeroes. */
    public function testSeedZeroBehavesLikeSeedOne() {
        var bitmap1 = new BitmapData(256, 256);
        var bitmap2 = new BitmapData(256, 256);

        bitmap1.noise(0);
        bitmap2.noise(1);

        for (y in 0...bitmap1.height) {
            for (x in 0...bitmap1.width) {
                assertEquals(bitmap1.getPixel(x, y), bitmap2.getPixel(x, y));
            }
        }
    }

   /* Proves that Flash generates noise one pixel at a time, from left-to-right, top-to-bottom. */
    public function testNoiseWrapsLeftToRightTopToBottom() {
        var bitmap1 = new BitmapData(256, 1024);
        var bitmap2 = new BitmapData(512, 512);

        bitmap1.noise(1);
        bitmap2.noise(1);

        for (i in 0...(bitmap1.width*bitmap1.height)) {
            var x1 = i % bitmap1.width;
            var y1 = Std.int(i / bitmap1.width);

            var x2 = i % bitmap2.width;
            var y2 = Std.int(i / bitmap2.width);

            assertEquals(bitmap1.getPixel(x1, y1), bitmap2.getPixel(x2, y2));
        }
    }

    /** Proves that Flash generates noise as follows:
     *
     * <ol><li>For each pixel, left-to-right, top-to-bottom:</li>
     * <li>For each unmasked channel, in the order R, G, B, A:</li>
     * <li>Fetch a random value from the noise generator, modulo reduce it to the range 0...255, and set the
     *   value of the current pixel-channel to that value.</li></ol>
     *
     * Note that Flash stores colours alpha pre-multiplied so, if A &lt; 255, there will be rounding errors in the RGB
     * values. */
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
                        // Compensate for loss caused by alpha pre-multiplication.
                        tmpBitmap.setPixel32(0, 0, alpha << 24 | expectedByte);
                        var expectedLossyByte = tmpBitmap.getPixel(0, 0);
                        assertEquals(expectedLossyByte, colour);
                    }
                }
            }
        }
    }

    /** Proves that the Flash noise generator is a MINSTD pseudo-random number generator.
     *
     * An example implementation of this generator is std::minstd_rand0 from the C++ standard library. */
    public function testNoiseGeneratorIsMinstd() {
        var seed = 38;

        var generator = new MinstdGenerator(seed);

        var bitmap = new BitmapData(256, 256);
        bitmap.noise(seed, 0, 255, BitmapDataChannel.BLUE);

        for (y in 0...bitmap.height) {
            for (x in 0...bitmap.width) {
                var expected = generator.nextValue() & 255;
                assertEquals(expected, bitmap.getPixel(x, y));
            }
        }
    }

    /** Proves that noise from the PRNG is modulo-reduced to the requested range. */
    public function testNoiseIsModuloReducedToTheRequestedRange() {
        var seed = 389;

        var bitmap = new BitmapData(256, 256);

        for (params in [
            {low: 0, high: 207},
            {low: 4, high: 24},
            {low: 87, high: 255}
        ]) {
            bitmap.noise(seed, params.low, params.high, BitmapDataChannel.BLUE);
            var generator = new MinstdGenerator(seed);

            for (y in 0...bitmap.height) {
                for (x in 0...bitmap.width) {
                    var expected = params.low + generator.nextValue() % (params.high-params.low+1);
                    assertEquals(expected, bitmap.getPixel(x, y));
                }
            }
        }
    }

    /** Proves that, when the grayscale flag is set, BitmapDataChannel.RED, .GREEN and .BLUE are ignored, and
     * so the resulting noise is always grayscale. */
    public function testChannelOptionsDoNotAffectGrayscaleNoise() {
        var seed = 899;

        var bitmap1 = new BitmapData(256, 256);
        var bitmap2 = new BitmapData(256, 256);
        var bitmap3 = new BitmapData(256, 256);
        var bitmap4 = new BitmapData(256, 256);

        bitmap1.noise(seed, 0, 255, BitmapDataChannel.RED, true);
        bitmap2.noise(seed, 0, 255, BitmapDataChannel.GREEN, true);
        bitmap3.noise(seed, 0, 255, BitmapDataChannel.BLUE, true);
        bitmap4.noise(seed, 0, 255, 0, true);

        for (y in 0...bitmap1.height) {
            for (x in 0...bitmap1.width) {
                assertEquals(bitmap1.getPixel(x, y), bitmap2.getPixel(x, y));
                assertEquals(bitmap1.getPixel(x, y), bitmap3.getPixel(x, y));
                assertEquals(bitmap1.getPixel(x, y), bitmap4.getPixel(x, y));
            }
        }
    }

    /** Proves that grayscale noise with no alpha contains identical noise values to single-channel noise. */
    public function testOneByteOfNoiseIsFetchedForGrayscaleWithNoAlpha() {
        var seed = 7893;

        var blueBitmap = new BitmapData(256, 256);
        var grayBitmap = new BitmapData(256, 256);

        blueBitmap.noise(seed, 0, 255, BitmapDataChannel.BLUE, false);
        grayBitmap.noise(seed, 0, 255, BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE, true);

        for (y in 0...blueBitmap.height) {
            for (x in 0...blueBitmap.width) {
                var bluePixel = blueBitmap.getPixel(x, y);
                var grayPixel = grayBitmap.getPixel(x, y);
                assertEquals(bluePixel, grayPixel & 0xff);
                assertEquals(bluePixel, grayPixel >> 8 & 0xff);
                assertEquals(bluePixel, grayPixel >> 16 & 0xff);
            }
        }
    }

    /** Proves that grayscale noise with alpha contains identical noise values to single-channel noise with alpha. */
    public function testGrayscaleNoiseIsFetchedForLuminanceThenAlpha() {
        var seed = 23890;

        var blueBitmap = new BitmapData(256, 256);
        var grayBitmap = new BitmapData(256, 256);

        blueBitmap.noise(seed, 0, 255, BitmapDataChannel.BLUE | BitmapDataChannel.ALPHA, false);
        grayBitmap.noise(seed, 0, 255, BitmapDataChannel.BLUE | BitmapDataChannel.ALPHA, true);

        for (y in 0...blueBitmap.height) {
            for (x in 0...grayBitmap.width) {
                var bluePixel = blueBitmap.getPixel32(x, y);
                var grayPixel = grayBitmap.getPixel32(x, y);
                assertEquals(bluePixel & 0xff, grayPixel & 0xff);
                assertEquals(bluePixel & 0xff, grayPixel >> 8 & 0xff);
                assertEquals(bluePixel & 0xff, grayPixel >> 16 & 0xff);
                assertEquals(grayPixel & 0xff000000, grayPixel & 0xff000000);
            }
        }
    }
}
