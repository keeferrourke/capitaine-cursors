#!/bin/bash

# Capitaine cursors, macOS inspired cursors based on KDE Breeze
# Copyright (c) 2016 Keefer Rourke <mail@krourke.org> and others.

SRC=$PWD/src
DIST=$PWD/dist
VARIANTS=('dark' 'light')
BUILD_DIR=$PWD/_build
SPECS="$SRC/config"
ALIASES="$SRC/cursor-aliases"
SIZES=('1' '1.5' '2' '2.5' '3' '4' '5' '6')
SVG_DIM=24

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
  return 1
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

generate_in
exit 0

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

  mkdir -p "$BUILD_DIR/$variant/$name"
  find "$SRC/svg/$variant" -name "*.svg" -type f \
      -exec sh -c 'inkscape -z -e "$1/$2/$3/$(basename ${0%.svg}).png" -w $4 -h $4 $0' {} "$BUILD_DIR" "$variant" "$name" "$size" \;
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

  # Generate the *.in files from the specs in the sources.
  generate_in

  # Move the in files and target variant to the root of the build directory
  # so that xcursorgen can find everything it needs.
  cp -r "$BUILD_DIR/$variant" "$BUILD_DIR"
  pushd "$BUILD_DIR" || return 1
  for cur_cfg in *.in; do
    cur_name="$(basename "${cur_cfg%.*}")"
    xcursorgen "$cur_cfg" "$OUTPUT_DIR/$cur_name"
  done
  popd || return 1

  pushd "$OUTPUT_DIR" || return 1
  while read -r cur_alias; do
    from="${cur_alias#* }"
    to="${cur_alias% *}"

    if [ -e "$to" ]; then continue; fi

    ln -sr "$from" "$to"
  done < "$ALIASES"
  popd || return 1

  if [ ! -e "$INDEX_FILE" ]; then
    touch "$INDEX_FILE"
    echo -e "[Icon Theme]\nName=$THEME\n" > "$INDEX_FILE"
  fi
}

# TODO: Accept variant arg from commandline.
variant=dark
for size in "${SIZES[@]}"; do
  render "$size" "$variant"
done
assemble "$variant"

exit 0