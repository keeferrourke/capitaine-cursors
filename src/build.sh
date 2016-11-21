#!/bin/bash

# Capitaine cursors, macOS inspired cursors based on KDE Breeze
# Copyright (c) 2016 Keefer Rourke <keefer.rourke@gmail.com>

# generate pixmaps from svg source
pushd .
SRC=$PWD

if [ ! -d "x1" ]; then
    mkdir "x1"
fi
if [ ! -d "x2" ]; then
    mkdir "x2"
fi

cd svg/
find . -name "*.svg" -type f -exec sh -c 'inkscape -z -e "../x1/${0%.svg}.png" -w 64 -h 64 $0' {} \;
find . -name "*.svg" -type f -exec sh -c 'inkscape -z -e "../x2/${0%.svg}.png" -w 80 -w 80 $0' {} \;

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
echo -e "Installing"
popd.
sudo rsync -rav build/ /usr/share/icons/capitaine-cursors/
echo -e "Installing... DONE"

