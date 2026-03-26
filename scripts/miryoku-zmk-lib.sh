#!/usr/bin/env bash

set -euo pipefail

miryoku_repo_root() {
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  cd -- "$script_dir/.." && pwd
}

MIRYOKU_REPO_ROOT="$(miryoku_repo_root)"
MIRYOKU_LOCAL_DIR="${MIRYOKU_ZMK_LOCAL_DIR:-$MIRYOKU_REPO_ROOT/.local}"
MIRYOKU_WORKSPACE="${MIRYOKU_ZMK_WORKSPACE:-$MIRYOKU_LOCAL_DIR/zmk-workspace}"
MIRYOKU_ZMK_DIR="$MIRYOKU_WORKSPACE/zmk"
MIRYOKU_VENV_DIR="$MIRYOKU_LOCAL_DIR/venv"
MIRYOKU_OUTBOARDS_DIR="$MIRYOKU_LOCAL_DIR/outboards"
MIRYOKU_MODULES_DIR="$MIRYOKU_LOCAL_DIR/modules"
MIRYOKU_ARTIFACTS_DIR="$MIRYOKU_LOCAL_DIR/artifacts"
MIRYOKU_OUTBOARD_MODULE_DIRS="${MIRYOKU_OUTBOARD_MODULE_DIRS:-}"

mkdir -p "$MIRYOKU_LOCAL_DIR" "$MIRYOKU_OUTBOARDS_DIR" "$MIRYOKU_MODULES_DIR" "$MIRYOKU_ARTIFACTS_DIR"

miryoku_default_zmk_branch() {
  printf '%s\n' "zmkfirmware/zmk/main"
}

miryoku_normalize_repo_url() {
  local repo="$1"
  if [[ "$repo" == https://* ]]; then
    printf '%s\n' "$repo"
  else
    printf 'https://github.com/%s.git\n' "$repo"
  fi
}

miryoku_clone_or_update() {
  local repo_url="$1"
  local ref="$2"
  local dir="$3"

  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" fetch --depth 1 origin "$ref"
    git -C "$dir" checkout --force FETCH_HEAD
  else
    rm -rf "$dir"
    git clone --depth 1 -b "$ref" "$repo_url" "$dir"
  fi
}

miryoku_activate_venv() {
  if [[ ! -x "$MIRYOKU_VENV_DIR/bin/python" ]]; then
    python3 -m venv "$MIRYOKU_VENV_DIR"
  fi

  # shellcheck disable=SC1091
  source "$MIRYOKU_VENV_DIR/bin/activate"
  python -m pip install --upgrade pip setuptools wheel >/dev/null
}

miryoku_keyboard_base() {
  local name="$1"

  name="${name%%@*}"
  case "$name" in
    *_left) name="${name%_left}" ;;
    *_right) name="${name%_right}" ;;
    *_dongle) name="${name%_dongle}" ;;
  esac

  printf '%s\n' "$name"
}

miryoku_load_outboard() {
  local kind="$1"
  local name="$2"
  local outboard_file="$MIRYOKU_REPO_ROOT/.github/workflows/outboards/$kind/$name"

  [[ -f "$outboard_file" ]] || return 0

  local outboard_repository=''
  local outboard_ref=''
  local outboard_from=''
  local outboard_to=''
  local outboard_branches=''
  local outboard_modules=''

  # shellcheck disable=SC1090
  source "$outboard_file"

  if [[ -n "$outboard_repository" && -n "$outboard_ref" && -n "$outboard_from" && -n "$outboard_to" ]]; then
    local repo_url
    local clone_dir
    local src
    local dest

    repo_url="$(miryoku_normalize_repo_url "$outboard_repository")"
    clone_dir="$MIRYOKU_OUTBOARDS_DIR/$kind/$name"
    mkdir -p "$(dirname -- "$clone_dir")"
    miryoku_clone_or_update "$repo_url" "$outboard_ref" "$clone_dir"

    src="$clone_dir/$outboard_from"
    dest="$MIRYOKU_REPO_ROOT/config/$outboard_to"
    mkdir -p "$(dirname -- "$dest")"
    rm -rf "$dest"
    ln -s "$src" "$dest"

    if [[ -f "$clone_dir/zephyr/module.yml" ]]; then
      case ";$MIRYOKU_OUTBOARD_MODULE_DIRS;" in
        *";$clone_dir;"*) ;;
        *) MIRYOKU_OUTBOARD_MODULE_DIRS="${MIRYOKU_OUTBOARD_MODULE_DIRS:+$MIRYOKU_OUTBOARD_MODULE_DIRS;}$clone_dir" ;;
      esac
    fi

  fi

  if [[ -n "$outboard_branches" ]]; then
    MIRYOKU_BRANCHES="${MIRYOKU_BRANCHES:+$MIRYOKU_BRANCHES }$outboard_branches"
  fi

  if [[ -n "$outboard_modules" ]]; then
    MIRYOKU_MODULE_SPECS="${MIRYOKU_MODULE_SPECS:+$MIRYOKU_MODULE_SPECS }$outboard_modules"
  fi
}

miryoku_prepare_outboards() {
  local board="$1"
  local shield="${2:-}"
  local keyboard
  local keyboard_base

  if [[ -n "$shield" ]]; then
    keyboard="${shield%% *}"
    keyboard_base="$(miryoku_keyboard_base "$keyboard")"
    miryoku_load_outboard "shields" "$keyboard_base"
    miryoku_load_outboard "boards" "$board"
  else
    keyboard="$board"
    keyboard_base="$(miryoku_keyboard_base "$keyboard")"
    miryoku_load_outboard "boards" "$keyboard_base"
  fi
}

miryoku_prepare_modules() {
  local module_dir=''
  local module_spec=''
  local repo_url=''
  local user=''
  local repo=''
  local branch=''
  local module_dirs="$MIRYOKU_OUTBOARD_MODULE_DIRS"

  if [[ -z "${MIRYOKU_MODULE_SPECS:-}" ]]; then
    if [[ -n "$module_dirs" ]]; then
      export ZMK_EXTRA_MODULES="$module_dirs"
    fi
    return 0
  fi

  for module_spec in $MIRYOKU_MODULE_SPECS; do
    user="$(printf '%s' "$module_spec" | cut -d '/' -f 1)"
    repo="$(printf '%s' "$module_spec" | cut -d '/' -f 2)"
    branch="$(printf '%s' "$module_spec" | cut -d '/' -f 3-)"
    repo_url="https://github.com/$user/$repo.git"
    module_dir="$MIRYOKU_MODULES_DIR/$user-$repo-$(printf '%s' "$branch" | tr '/' '_')"
    miryoku_clone_or_update "$repo_url" "$branch" "$module_dir"
    module_dirs="${module_dirs:+$module_dirs;}$module_dir"
  done

  if [[ -n "$module_dirs" ]]; then
    export ZMK_EXTRA_MODULES="$module_dirs"
  fi
}

miryoku_prepare_zmk_repo() {
  local branches_string="${MIRYOKU_BRANCHES:-$(miryoku_default_zmk_branch)}"
  local zmk_spec user repo branch repo_url merge remote

  zmk_spec="${branches_string%% *}"
  user="$(printf '%s' "$zmk_spec" | cut -d '/' -f 1)"
  repo="$(printf '%s' "$zmk_spec" | cut -d '/' -f 2)"
  branch="$(printf '%s' "$zmk_spec" | cut -d '/' -f 3-)"
  repo_url="https://github.com/$user/$repo.git"

  miryoku_clone_or_update "$repo_url" "$branch" "$MIRYOKU_ZMK_DIR"

  if [[ "$branches_string" == *" "* ]]; then
    git -C "$MIRYOKU_ZMK_DIR" fetch --unshallow || true
    for merge in ${branches_string#* }; do
      user="$(printf '%s' "$merge" | cut -d '/' -f 1)"
      repo="$(printf '%s' "$merge" | cut -d '/' -f 2)"
      branch="$(printf '%s' "$merge" | cut -d '/' -f 3-)"
      remote="$user-$repo"
      git -C "$MIRYOKU_ZMK_DIR" remote remove "$remote" >/dev/null 2>&1 || true
      git -C "$MIRYOKU_ZMK_DIR" remote add "$remote" "https://github.com/$user/$repo.git"
      git -C "$MIRYOKU_ZMK_DIR" fetch "$remote" "$branch"
      git -C "$MIRYOKU_ZMK_DIR" merge --no-edit "$remote/$branch"
      git -C "$MIRYOKU_ZMK_DIR" remote remove "$remote"
    done
  fi
}

miryoku_setup_workspace() {
  miryoku_activate_venv
  miryoku_prepare_zmk_repo
  miryoku_prepare_modules

  if [[ ! -d "$MIRYOKU_ZMK_DIR/.west" ]]; then
    (cd "$MIRYOKU_ZMK_DIR" && west init -l app)
  fi

  (cd "$MIRYOKU_ZMK_DIR" && west update && west zephyr-export)

  python -m pip install -r "$MIRYOKU_ZMK_DIR/zephyr/scripts/requirements.txt" >/dev/null
  python -m pip install -r "$MIRYOKU_ZMK_DIR/app/scripts/requirements.txt" >/dev/null
}

miryoku_build() {
  local board="$1"
  local shield="${2:-}"
  local build_log
  local artifact_name
  local artifact_dir
  local ext
  local -a cmd=(west build)
  local -a extra_cmake_args=()

  if [[ "${MIRYOKU_ZMK_PRISTINE:-0}" == "1" ]]; then
    cmd+=(-p)
  fi

  export ZMK_CONFIG="${ZMK_CONFIG:-$MIRYOKU_REPO_ROOT/config}"
  export ZEPHYR_TOOLCHAIN_VARIANT="${ZEPHYR_TOOLCHAIN_VARIANT:-gnuarmemb}"
  export GNUARMEMB_TOOLCHAIN_PATH="${GNUARMEMB_TOOLCHAIN_PATH:-}"

  if [[ -n "$shield" ]]; then
    artifact_name="$(printf '%s-%s' "$board" "$shield" | tr ' /' '__')"
  else
    artifact_name="$board"
  fi

  artifact_dir="$MIRYOKU_ARTIFACTS_DIR/$artifact_name"
  rm -rf "$artifact_dir"
  mkdir -p "$artifact_dir"

  build_log="$artifact_dir/build.log"

  cmd+=(-b "$board" --)
  if [[ -n "$shield" ]]; then
    cmd+=("-DSHIELD=$shield")
  fi
  if [[ -n "${ZMK_EXTRA_MODULES:-}" ]]; then
    cmd+=("-DZMK_EXTRA_MODULES=$ZMK_EXTRA_MODULES")
  fi
  cmd+=("-DZMK_CONFIG=$ZMK_CONFIG")
  if [[ -n "${MIRYOKU_ZMK_CMAKE_ARGS:-}" ]]; then
    # shellcheck disable=SC2206
    extra_cmake_args=(${MIRYOKU_ZMK_CMAKE_ARGS})
    cmd+=("${extra_cmake_args[@]}")
  fi

  (
    cd "$MIRYOKU_ZMK_DIR/app"
    "${cmd[@]}"
  ) 2>&1 | tee "$build_log"

  for ext in uf2 bin hex elf; do
    if [[ -f "$MIRYOKU_ZMK_DIR/app/build/zephyr/zmk.$ext" ]]; then
      cp "$MIRYOKU_ZMK_DIR/app/build/zephyr/zmk.$ext" "$artifact_dir/"
    fi
  done

  if [[ -f "$MIRYOKU_ZMK_DIR/app/build/zephyr/.config" ]]; then
    cp "$MIRYOKU_ZMK_DIR/app/build/zephyr/.config" "$artifact_dir/zephyr.config"
  fi

  printf 'Artifacts: %s\n' "$artifact_dir"
}
