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


#define KEYS_L K00 K01 K02 K03 K04 K10 K11 K12 K13 K14 K20 K21 K22 K23 K24  // Left-hand keys.
#define KEYS_R K05 K06 K07 K08 K09 K15 K16 K17 K18 K19 K25 K26 K27 K28 K29  // Right-hand keys.
#define THUMBS K32 K33 K34 K35 K36 K37                                      // Thumb keys.

#endif

#define MIRYOKU_MAPPING MIRYOKU_LAYOUTMAPPING_TORNBLUE
