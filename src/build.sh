#!/bin/bash

# Capitaine cursors, macOS inspired cursors based on KDE Breeze
# Copyright (c) 2016 Keefer Rourke <keefer.rourke@gmail.com>

# generate pixmaps from svg source
SRC=$PWD
SVG="svg"

if [ "$1" == "--light" ]; then
	if [ ! -d "svg-light" ]; then
    mkdir "svg-light"
	fi
	SVG="svg-light"
	for file in svg/* ; do
		if [[ $(basename $file .svg) =~ (not-allowed|wayland-cursor|zoom-in|zoom-out) ]] ; then
			cat $file > svg-light/$(basename $file)
			continue
		fi
		awk -f swap.awk $file > svg-light/$(basename $file)
	done
fi

if [ ! -d "x1" ]; then
    mkdir "x1"
fi
if [ ! -d "x2" ]; then
    mkdir "x2"
fi

cd $SVG
find . -name "*.svg" -type f -exec sh -c 'inkscape -z -e "../x1/${0%.svg}.png" -w 32 -h 32 $0' {} \;
find . -name "*.svg" -type f -exec sh -c 'inkscape -z -e "../x2/${0%.svg}.png" -w 64 -w 64 $0' {} \;

cd $SRC

# generate cursors
BUILD="$SRC"/build
OUTPUT="$BUILD"/cursors
ALIASES="$SRC"/cursorList

if [ ! -d "$BUILD" ]; then
    mkdir "$BUILD"
fi
if [ ! -d "$OUTPUT" ]; then
    mkdir "$OUTPUT"
fi

echo -ne "Generating cursor theme...\\r"
for CUR in config/*.cursor; do
	BASENAME="$CUR"
	BASENAME="${BASENAME##*/}"
	BASENAME="${BASENAME%.*}"
	
	xcursorgen "$CUR" "$OUTPUT/$BASENAME"
done
echo -e "Generating cursor theme... DONE"

cd "$OUTPUT"	

#generate aliases
echo -ne "Generating shortcuts...\\r"
while read ALIAS; do
	FROM="${ALIAS#* }"
	TO="${ALIAS% *}"

	if [ -e $TO ]; then
		continue
	fi
	ln -sr "$FROM" "$TO"
done < "$ALIASES"
echo -e "Generating shortcuts... DONE"

cd "$PWD"

echo -ne "Generating Theme Index...\\r"
INDEX="$OUTPUT/../index.theme"
if [ ! -e "$OUTPUT/../$INDEX" ]; then
	touch "$INDEX"
	echo -e "[Icon Theme]\nName=Capitaine Cursors\n" > "$INDEX"
fi
echo -e "Generating Theme Index... DONE"
