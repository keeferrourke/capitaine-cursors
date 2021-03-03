#!/bin/bash

# Capitaine cursors, macOS inspired cursors based on KDE Breeze
# Copyright (c) 2016 Keefer Rourke <mail@krourke.org> and others.

SRC=$PWD/src
DIST=$PWD/dist
VARIANTS=('dark' 'light')
PLATFORMS=('unix' 'win32')
BUILD_DIR=$PWD/_build
SPECS="$SRC/config"
ALIASES="$SRC/cursor-aliases"
SIZES=('1' '1.25' '1.5' '2' '2.5' '3' '4' '5' '6' '10')
DPIS=('lo' 'tv' 'hd' 'xhd' 'xxhd' 'xxxhd')
SVG_DIM=24
SVG_DPI=96

# Truncates $SIZES based on the specified max DPI.
# See https://en.wikipedia.org/wiki/Pixel_density#Named_pixel_densities
#
# Args:
#   $1 = lo, tv, hd, xhd, xxhd, xxxhd
#
function set_sizes {
  max_size="$1"
  case $max_size in
    lo)
      SIZES=("${SIZES[@]:0:3}")
      ;;
    tv)
      SIZES=("${SIZES[@]:0:4}")
      ;;
    hd)
      SIZES=("${SIZES[@]:0:5}")
      ;;
    xhd)
      SIZES=("${SIZES[@]:0:6}")
      ;;
    xxhd)
      SIZES=("${SIZES[@]:0:7}")
      ;;
    xxxhd)
      SIZES=("${SIZES[@]}")
      ;;
    *)
      return 1
      ;;
  esac
}

# Scales cursor specs to create an xcursor.in file for each cursor spec.
# The xcursor.in file line-format is as follows:
#
#   size xhot yhot filename [ms-delay]
#
# See `man 1 xcursorgen` for more details.
#
# Spec files are a custom format that I created, as follows:
#
#   xhot yhot [frames ms-delay]
#
function generate_in {
  mkdir -p "$BUILD_DIR"

  # Generate .in files for static cursors.
  for spec in "$SPECS"/static/*.spec; do
    IFS=" " read -r xhot_spec yhot_spec < "$spec"
    cur_name="$(basename "${spec%.*}")"
    target="$BUILD_DIR/$cur_name.in"
    if [ -f "$target" ]; then rm "$target"; fi
    for size in "${SIZES[@]}"; do
      dim=$(echo "$SVG_DIM*$size" | bc)
      xhot=$(echo "$xhot_spec*$size" | bc)
      yhot=$(echo "$yhot_spec*$size" | bc)
      dim=${dim%.*} xhot=${xhot%.*} yhot=${yhot%.*} # Strip decimals parts if any.
      echo "$dim $xhot $yhot x$size/$cur_name.png" | tee -a "$target"
    done
  done
  # Generate .in files for animated cursors.
  for spec in "$SPECS"/animated/*.spec; do
    IFS=" " read -r xhot_spec yhot_spec frames delay < "$spec"
    cur_name="$(basename "${spec%.*}")"
    target="$BUILD_DIR/$cur_name.in"
    if [ -f "$target" ]; then rm "$target"; fi
    for size in "${SIZES[@]}"; do
      dim=$(echo "$SVG_DIM*$size" | bc)
      xhot=$(echo "$xhot_spec*$size" | bc)
      yhot=$(echo "$yhot_spec*$size" | bc)
      dim=${dim%.*} xhot=${xhot%.*} yhot=${yhot%.*} # Strip decimals parts if any.
      for ((i=0; i < frames ; i++)); do
        i_pad=$(printf "%02d" $i)
        echo "$dim $xhot $yhot x$size/$cur_name-$i_pad.png $delay" | tee -a "$target"
      done
    done
  done
}

# Renders the source SVGs to PNGs in the $BUILD_DIR.
#
# Args:
#  $1 = 1, 1.5, 2, 2.5, 3, 4, 5, 6, ..
#  $2 = dark, light
#
function render {
  name="x$1"
  variant="$2"
  size=$(echo "$SVG_DIM*$1" | bc)
  dpi=$(echo "$SVG_DPI*$1" | bc)

  size=${size%.*} dpi=${size%.*} # Strip decimal parts if any.

  OUTPUT_DIR="$BUILD_DIR/$variant/$name"
  mkdir -p "$OUTPUT_DIR"

  # Set options for Inkscape depending on version.
  INKSCAPE_OPTS=('-w' "$size" -h "$size" -d "$dpi" )
  case $(inkscape -V | cut -d' ' -f2) in
    # NB: The export option (-e or -o) must be the last option in the INKSCAPE_OPTS array.
    0.*) INKSCAPE_OPTS+=('-z' '-e');; # -z specifies not to launch GUI, -e is export
    1.*) INKSCAPE_OPTS+=('-o');;      # v1.0+ uses no GUI by default, -e replaced by -o
  esac

  for svg_file in "$SRC/svg/$variant"/*.svg; do
   inkscape "${INKSCAPE_OPTS[@]}" "$OUTPUT_DIR/$(basename "${svg_file%.svg}").png" "$svg_file"
  done
}

# Assembles rendered PNGs into a cursor distribution.
#
# Args:
#  $1 = dark, light
#
function assemble {
  variant="$1"

  BASE_DIR="$DIST/$variant"
  OUTPUT_DIR="$BASE_DIR/cursors"
  INDEX_FILE="$BASE_DIR/index.theme"
  THEME_NAME="Capitaine Cursors"

  case "$variant" in
    dark) THEME_NAME="$THEME_NAME" ;;
    light) THEME_NAME="$THEME_NAME - White" ;;
    *) exit 1 ;;
  esac

  mkdir -p "$BASE_DIR"
  mkdir -p "$OUTPUT_DIR"

  # Move the in files and target variant to the root of the build directory
  # so that xcursorgen can find everything it needs.
  cp -r "$BUILD_DIR/$variant"/* "$BUILD_DIR"
  pushd "$BUILD_DIR" > /dev/null || return 1
  for cur_cfg in *.in; do
    cur_name="$(basename "${cur_cfg%.*}")"
    xcursorgen "$cur_cfg" "$OUTPUT_DIR/$cur_name"
  done
  popd > /dev/null || return 1

  pushd "$OUTPUT_DIR" > /dev/null || return 1
  while read -r cur_alias; do
    from="${cur_alias#* }"
    to="${cur_alias% *}"

    if [ -e "$to" ]; then continue; fi

    ln -s "$from" "$to"
  done < "$ALIASES"
  popd > /dev/null || return 1

  # Write the index.theme file.
  if [ ! -e "$INDEX_FILE" ]; then
    touch "$INDEX_FILE"
    echo -e "[Icon Theme]\nName=$THEME_NAME\nComment=A stylish cursor for humans" > "$INDEX_FILE"
  fi

  # Copy a thumbnail.png to serve as a preview in some environments.
  cp "$SRC/thumbnail-$variant.png" "$OUTPUT_DIR/thumbnail.png"
}

function show_usage {
  echo -e "This script builds the capitaine-cursor theme.\n"
  echo -e "Usage: ./build.sh [ -d DPI ] [ -t VARIANT ] [ -p PLATFORM ]"
  echo -e "  -h, --help\t\tPrint this help"
  echo -e "  -d, --max-dpi\t\tSet the max DPI to render. Higher values take longer."
  echo -e                "\t\t\tOne of (" "${DPIS[@]}" ")."
  echo -e "  -t, --type\t\tSpecify the build variant. One of (" "${VARIANTS[@]}" ")."
  echo -e "  -p, --platform\tSpecify the build platform. One of (" "${PLATFORMS[@]}" ")."
  echo
}

function validate_option {
  valid=0
  case "$1" in
    variant)
      for variant in "${VARIANTS[@]}"; do
        if [[ "$2" == "$variant" ]]; then valid=1; fi
      done
      ;;
    platform)
      for platform in "${PLATFORMS[@]}"; do
        if [[ "$2" == "$platform" ]]; then valid=1; fi
      done
      ;;
    *) return 1 ;;
  esac
  test "$valid" -eq 1
  return $?
}

# Check dependencies are present.
DEPENDENCIES=(inkscape xcursorgen bc)
for dep in "${DEPENDENCIES[@]}"; do
  if ! command -v "$dep" >/dev/null; then
    echo "$dep is not installed, exiting."
    exit 1
  fi
done

# Parse options to script.
POSITIONAL_ARGS=()
VARIANT="${VARIANTS[0]}"    # Default = dark
PLATFORM="${PLATFORMS[0]}"  # Default = unix
MAX_DPI=${DPIS[1]}          # Default = tv
while [[ $# -gt 0 ]]; do
  opt="$1"
  case $opt in
    -h|--help)
      show_usage
      exit 0
      ;;
    -d|--max-dpi)
      MAX_DPI="$2"
      shift; shift; # Shift past option and value.
      ;;
    -t|--type)
      VARIANT="$2"
      validate_option 'variant' "$VARIANT" || { show_usage; exit 2; }
      shift ; shift; # Shift past option and value.
      ;;
    -p|--platform)
      PLATFORM="$2"
      validate_option 'platform' "$PLATFORM" || { show_usage; exit 2; }
      shift; shift; # Shift past option and value.
      ;;
    -*=*)
      echo "Unrecognized argument, use --opt value instead of --opt=value"
      exit 2
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift # Shift past the value.
      ;;
  esac
done
# Restore positional arguments.
set -- "${POSITIONAL_ARGS[@]}"

# Begin the build.
set_sizes "$MAX_DPI" || { echo "Unrecognized DPI."; exit 1; }
generate_in

for size in "${SIZES[@]}"; do
  render "$size" "$VARIANT"
done
assemble "$VARIANT"

exit 0
