package reverse_noise;

/** A MINSTD pseudo-random number generator.
 *
 * This generates a pseudo-random number sequence equivalent to std::minstd_rand0 from the C++ standard library, which
 * is the generator that Flash uses to generate noise for BitmapData.noise().
 *
 * MINSTD was originally suggested in "A pseudo-random number generator for the System/360", P.A. Lewis, A.S. Goodman,
 * J.M. Miller, IBM Systems Journal, Vol. 8, No. 2, 1969, pp. 136-146 */
class MinstdGenerator {
    static inline var a = 16807;
    static inline var m = (1 << 31) - 1;

    var value:Int;

    public function new(seed:Int) {
        if (seed == 0) {
            this.value = 1;
        } else {
            this.value = seed;
        }
    }

    public function nextValue():Int {
        var lo = a * (value & 0xffff);
        var hi = a * (value >>> 16);
        lo += (hi & 0x7fff) << 16;

        if (lo < 0 || lo > m) {
            lo &= m;
            ++lo;
        }

        lo += hi >>> 15;

        if (lo < 0 || lo > m) {
            lo &= m;
            ++lo;
        }

        return value = lo;
    }
}
