package reverse_noise;

/** A MINSTD pseudo-random number generator.
 *
 * This is equivalent to std::minstd_rand0 from the C++ standard library. **/
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
