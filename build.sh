#!/bin/bash

# Capitaine cursors, macOS inspired cursors based on KDE Breeze
# Copyright (c) 2016 Keefer Rourke <keefer.rourke@gmail.com>

# generate cursors
PWD=$(pwd)
OUTPUT="$PWD"/build/cursors
ALIASES="$PWD"/cursorList

echo -ne "Generating cursor theme...\\r"
for CUR in config/*.cursor; do
	BASENAME=$CUR
	BASENAME=${BASENAME##*/}
	BASENAME=${BASENAME%.*}
	
	xcursorgen $CUR $OUTPUT/$BASENAME
done
echo -e "Generating cursor theme... DONE"

cd $OUTPUT	

#generate aliases
echo -ne "Generating shortcuts...\\r"
while read ALIAS; do
	FROM=${ALIAS#* }
	TO=${ALIAS% *}

	if [ -e $TO ]; then
		continue
	fi
	ln -sr "$FROM" "$TO"
done < $ALIASES
echo -e "Generating shortcuts... DONE"

cd $PWD

echo -ne "Generating Theme Index...\\r"
INDEX="$OUTPUT/index.theme"
if ! [ -e $OUTPUT/$INDEX ]; then
	touch $INDEX
	echo -e "[Icon Theme]\nName=Capitaine Cursors\n" > index.theme
fi
echo -e "Generating Theme Index... DONE"
