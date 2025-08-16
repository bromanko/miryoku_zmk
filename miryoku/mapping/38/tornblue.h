// Copyright 2022 Manna Harbour
// https://github.com/manna-harbour/miryoku

#if !defined (MIRYOKU_LAYOUTMAPPING_TORNBLUE)

#define XXX &none

#define MIRYOKU_LAYOUTMAPPING_TORNBLUE( \
K00, K01, K02, K03, K04,                K05, K06, K07, K08, K09, \
K10, K11, K12, K13, K14,                K15, K16, K17, K18, K19, \
K20, K21, K22, K23, K24,                K25, K26, K27, K28, K29, \
N30, N31, K32, K33, K34,                K35, K36, K37, N38, N39 \
) \
XXX  K00  K01  K02  K03  K04       K05  K06  K07  K08  K09  XXX \
XXX  K10  K11  K12  K13  K14       K15  K16  K17  K18  K19  XXX \
XXX  K20  K21  K22  K23  K24       K25  K26  K27  K28  K29  XXX \
          XXX  K32  K33  K34       K35  K36  K37  XXX


#define KEYS_L 0 1 2 3 4 10 11 12 13 14 20 21 22 23 24  // Left-hand keys.
#define KEYS_R 5 6 7 8 9 15 16 17 18 19 25 26 27 28 29  // Right-hand keys.
#define THUMBS 30 31 32 33 34 35                        // Thumb keys.

#endif

#define MIRYOKU_MAPPING MIRYOKU_LAYOUTMAPPING_TORNBLUE
