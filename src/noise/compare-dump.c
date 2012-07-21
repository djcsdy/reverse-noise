#include <stdio.h>

#define SEED 3

typedef int (* generator_t)();

/* Linear congruential generators */

/* Numerical Recipes */
int lcg1() {
    static unsigned int a = 1664525;
    static unsigned int c = 1013904223;
    static unsigned int x = SEED;

    x = (a * x + c) & 0xffffffffu;
    return x & 0xff;
}

/* Borland C lrand() */
int lcg2() {
    static unsigned int a = 22695477;
    static unsigned int c = 1;
    static unsigned int x = SEED;

    x = (a * x + c) & 0xffffffffu;
    return x & 0xff;
}

/* Borland C rand() */
int lcg3() {
    static unsigned int a = 22695477;
    static unsigned int c = 1;
    static unsigned int x = SEED;

    x = (a * x + c) & 0xffffffffu;
    return x >> 16 & 0xff;
}

/* glibc */
int lcg4() {
    static unsigned int a = 1103515245;
    static unsigned int c = 12345;
    static unsigned int x = SEED;

    x = (a * x + c) & 0x8fffffffu;
    return x & 0xff;
}

/* ANSI C: Watcom, Digital Mars, CodeWarrior, IBM VisualAge C */
int lcg5() {
    static unsigned int a = 1103515245;
    static unsigned int c = 12345;
    static unsigned int x = SEED;

    x = (a * x + c) & 0x8fffffffu;
    return x >> 16 & 0xff;
}

/* Delphi/Borland Pascal */
int lcg6() {
    static unsigned int a = 134775813;
    static unsigned int c = 1;
    static unsigned int x = SEED;

    x = (a * x + c) & 0xffffffffu;
    return x >> 16 & 0xff;
}

/* Visual C */
int lcg7() {
    static unsigned int a = 214013;
    static unsigned int c = 2531011;
    static unsigned int x = SEED;

    x = (a * x + c) & 0xffffffffu;
    return x >> 16 & 0xff;
}

/* Visual Basic <= 6 */
int lcg8() {
    static unsigned int a = 1140671485;
    static unsigned int c = 12820163;
    static unsigned int x = SEED;

    x = (a * x + c) & 0xffffffu;
    return x & 0xff;
}

/* RtlUniform from Native API */
int lcg9() {
    static unsigned int m = (1 << 31) - 1;
    static unsigned int a = 2147483629;
    static unsigned int c = 2147483587;
    static unsigned int x = SEED;

    x = (a * x + c) % m;
    return x & 0xff;
}

/* MINSTD */
int lcg10() {
    static unsigned int m = (1 << 31) - 1;
    static unsigned int a = 16807;
    static unsigned int c = 0;
    static unsigned int x = SEED;

    x = (a * x + c) % m;
    return x & 0xff;
}

/* MMIX */
int lcg11() {
    static unsigned long long a = 6364136223846793005ull;
    static unsigned long long c = 1442695040888963407ull;
    static unsigned long long x = SEED;

    x = (a * x + c) & 0xffffffffffffffffull;
    return x & 0xff;
}

/* VAX MTH$RANDOM, old glibc */
int lcg12() {
    static unsigned int a = 69069;
    static unsigned int c = 1;
    static unsigned int x = SEED;

    x = (a * x + c) & 0xffffffffu;
    return x & 0xff;
}

/* java.util.Random */
int lcg13() {
    static unsigned long long a = 25214903917ull;
    static unsigned long long c = 11ull;
    static unsigned long long x = SEED;

    x = (a * x + c) & 0xffffffffffffull;
    return x >> 16 & 0xff;
}

/* LC53 in Forth */
int lcg14() {
    static unsigned int m = -5;
    static unsigned int a = -333333333;
    static unsigned int c = 0;
    static unsigned int x = SEED;

    x = (a * x + c) % m;
    return x & 0xff;
}


/* Main */

void main() {
    generator_t generators[] = {
        &lcg1, &lcg2, &lcg3, &lcg4, &lcg5, &lcg6, &lcg7, &lcg8, &lcg9, &lcg10,
        &lcg11, &lcg12, &lcg13, &lcg14
    };

    int num_generators = sizeof(generators) / sizeof(generator_t);

    int num_generators_remaining = num_generators;

    int generator_active[sizeof(generators) / sizeof(generator_t)];

    int generator_index, position, matches, value, byte, generated_byte;

    for (generator_index=0; generator_index<num_generators; ++generator_index) {
        generator_active[generator_index] = 1;
    }

    position = 0;
    while (num_generators_remaining > 0
            && (matches = scanf("%d\n", &value)) >= 0) {
        if (matches == 0) {
            getchar();
        } else {
            do {
                byte = (value >> (16 - (position % 3) * 8)) & 0xff;

                for (generator_index=0; generator_index<num_generators; ++generator_index) {
                    if (generator_active[generator_index]) {
                        generated_byte = generators[generator_index]();
                        if (generated_byte != byte) {
                            generator_active[generator_index] = 0;
                            --num_generators_remaining;
                            printf("Generator %d didn't match at position %d: source: %d, generated: %d\n",
                                    generator_index, position, byte, generated_byte);
                        }
                    }
                }

                ++position;
            } while (num_generators_remaining > 0
                    && position % 3 != 0);
        }
    }

    if (num_generators_remaining > 0) {
        for (generator_index=0; generator_index<num_generators; ++generator_index) {
            if (generator_active[generator_index]) {
                printf("Generator %d matched the sequence of %d bytes!\n", generator_index, position);
            }
        }
    } else {
        printf("After %d bytes, no generators matched.\n", position);
    }
}
