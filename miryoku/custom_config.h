// Copyright 2026 Manna Harbour
// https://github.com/manna-harbour/miryoku

#pragma once

#define MIRYOKU_CLIPBOARD_MAC

// Match the preferred Tornblue Miryoku base layout while keeping the
// modifiers-layer holds on Z and / instead of the thumb keys.
#define MIRYOKU_LAYER_BASE                                                     \
  &kp Q, &kp W, &kp F, &kp P, &kp B, &kp J, &kp L, &kp U, &kp Y, &kp SQT,      \
      &kp A, &kp R, &kp S, &kp T, &kp G, &kp M, &kp N, &kp E, &kp I, &kp O,    \
      U_LT(U_MODS_LEFT, Z), U_MT(RALT, X), &kp C, &kp D, &kp V, &kp K, &kp H,  \
      &kp COMMA, U_MT(RALT, DOT), U_LT(U_MODS_RIGHT, SLASH), U_NP, U_NP,       \
      U_LT(U_MEDIA, ESC), U_LT(U_NAV, SPACE), U_LT(U_WM, TAB),                 \
      U_LT(U_SYM, RET), U_LT(U_NUM, BSPC), U_LT(U_FUN, DEL), U_NP, U_NP

// Shift the mods inward so CMD is on G/M, then Shift, Ctrl, Alt moving out.
#define MIRYOKU_LAYER_MODS_LEFT                                                \
  &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans,      \
      &trans,                                                                   \
      &trans, &kp LALT, &kp LCTRL, &kp LSHFT, &kp LGUI, &trans, &trans,        \
      &trans, &trans, &trans,                                                   \
      &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans,          \
      &trans, &trans,                                                           \
      &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans,          \
      &trans, &trans

#define MIRYOKU_LAYER_MODS_RIGHT                                               \
  &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans,      \
      &trans,                                                                   \
      &trans, &trans, &trans, &trans, &trans, &kp RGUI, &kp RSHFT, &kp RCTRL,  \
      &kp RALT, &trans,                                                         \
      &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans,          \
      &trans, &trans,                                                           \
      &trans, &trans, &trans, &trans, &trans, &trans, &trans, &trans,          \
      &trans, &trans

// Shift the right-hand nav arrows inward so N/E/I are down/up/right and M is left.
#define MIRYOKU_LAYER_NAV                                                      \
  U_BOOT, &u_to_U_TAP, &u_to_U_EXTRA, &u_to_U_BASE, U_NA, U_RDO, U_PST,        \
      U_CPY, U_CUT, U_UND,                                                     \
      &kp LGUI, &kp LALT, &kp LCTRL, &kp LSHFT, U_NA, &kp LEFT, &kp DOWN,      \
      &kp UP, &kp RIGHT, &u_caps_word,                                         \
      U_NA, &kp RALT, &u_to_U_NUM, &u_to_U_NAV, U_NA, &kp INS, &kp HOME,       \
      &kp PG_DN, &kp PG_UP, &kp END,                                           \
      U_NP, U_NP, U_NA, U_NA, U_NA, &kp RET, &kp BSPC, &kp DEL, U_NP, U_NP

// Shift the right-hand media cluster inward to match the nav/mods offset.
#define MIRYOKU_LAYER_MEDIA                                                    \
  U_BOOT, &u_to_U_TAP, &u_to_U_EXTRA, &u_to_U_BASE, U_NA, U_RGB_TOG,           \
      U_RGB_EFF, U_RGB_HUI, U_RGB_SAI, U_RGB_BRI,                              \
      &kp LGUI, &kp LALT, &kp LCTRL, &kp LSHFT, U_NA, &kp C_PREV,              \
      &kp C_VOL_DN, &kp C_VOL_UP, &kp C_NEXT, U_EP_TOG,                        \
      U_NA, &kp RALT, &u_to_U_FUN, &u_to_U_MEDIA, U_NA, &u_out_tog,            \
      &u_bt_sel_0, &u_bt_sel_1, &u_bt_sel_2, &u_bt_sel_3,                      \
      U_NP, U_NP, U_NA, U_NA, U_NA, &kp C_STOP, &kp C_PP, &kp C_MUTE, U_NP,   \
      U_NP
