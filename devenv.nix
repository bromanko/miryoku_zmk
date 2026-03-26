{ pkgs, lib, ... }:

{
  packages =
    with pkgs;
    [
      bashInteractive
      ccache
      cmake
      dtc
      file
      gcc-arm-embedded
      git
      gnumake
      gnugrep
      gperf
      jq
      ninja
      pkg-config
      python3
      python3Packages.pip
      python3Packages.pyelftools
      python3Packages.setuptools
      python3Packages.west
      wget
      which
    ]
    ++ lib.optionals stdenv.isDarwin [ libiconv ];

  enterShell = ''
    export ZMK_CONFIG="$PWD/config"
    export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
    export GNUARMEMB_TOOLCHAIN_PATH="${pkgs.gcc-arm-embedded}"
    export MIRYOKU_ZMK_LOCAL_DIR="$PWD/.local"
    export MIRYOKU_ZMK_WORKSPACE="$MIRYOKU_ZMK_LOCAL_DIR/zmk-workspace"
    export PATH="$PWD/scripts:$PATH"

    mkdir -p "$MIRYOKU_ZMK_LOCAL_DIR"

    echo "Miryoku ZMK devenv ready"
    echo "  init:  miryoku-zmk-init"
    echo "  build: miryoku-zmk-build nice_nano corne_left"
    echo "         miryoku-zmk-build nice_nano_v2 \"corne_left nice_view_adapter nice_view\""
  '';
}
