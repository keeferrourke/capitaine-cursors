#!/bin/bash

# Capitaine cursors, macOS inspired cursors based on KDE Breeze
# Copyright (c) 2016 Keefer Rourke <keefer.rourke@gmail.com>

# generate pixmaps from svg source

export SMALL_SIZE=80
export LARGE_SIZE=100

SRC=$PWD

if [ ! -d "x1" ]; then
    mkdir "x1"
fi
if [ ! -d "x2" ]; then
    mkdir "x2"
fi

cd svg/
sh -c 'for f in *.svg ; do echo $f; rsvg-convert -o "../x1/$(echo $f | sed s/.svg/.png/)" -w ${SMALL_SIZE} -h ${SMALL_SIZE} "$f"; done'
sh -c 'for f in *.svg ; do echo $f; rsvg-convert -o "../x2/$(echo $f | sed s/.svg/.png/)" -w ${LARGE_SIZE} -h ${LARGE_SIZE} "$f"; done'
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
config/conv.py ${SMALL_SIZE} ${LARGE_SIZE}
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
cd $SRC
sudo rsync -rav build/ /usr/share/icons/capitaine-cursors/
echo -e "Installing... DONE"

