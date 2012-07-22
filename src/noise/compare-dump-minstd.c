#include <stdio.h>

/* It looks very much like Flash uses a variant of MINSTD as its noise generator.
 * 
 * Specifically it appears to be a Lehmer random number generator:
 *
 * x_(k+1) = g * x_k mod n
 *
 * where g = 16807 (from MINSTD), and n is unknown.
 *
 * so, let's just brute force n. */

#define SEED 3

void main() {
    unsigned long long n;
    for (n=2147483647ull; n>=256; --n) {
        if (try(n)) {
            return;
        }
    }
}

int try(unsigned long long n) {
    int matches;
    unsigned long long position = 0;
    static int highest_position = 0;
    int value, byte, generated_byte;
    unsigned long long x = SEED;

    FILE *input = fopen("dump.txt", "r");
    while ((matches = fscanf(input, "%d\n", &value)) >= 0) {
        if (matches == 0) {
            fgetc(input);
        } else {
            do {
                byte = (value >> (16 - (position % 3) * 8)) & 0xff;

                x = (16807 * x) % n;
                generated_byte = x & 0xff;

                if (byte != generated_byte) {
                    if (position > highest_position) {
                        highest_position = position;
                        printf("n = %llu matched up to position %llu, then failed\n", n, position);
                    }
                    fclose(input);
                    return 0;
                }

                ++position;
            } while (position % 3 != 0);
        }

        if ((n & 0xffff) == 0) {
            printf("Passed n = %u\n", n);
        }
    }

    printf("n = %llu matched all %llu values!\n", n, position);
    fclose(input);
    return 1;
}