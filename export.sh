#!/bin/sh
echo "export all signs... processing"
mkdir tmp
rm -rf tmp/*
for f in res/img/*/*.svg; do
	inkscape $f -w 128 -h 128 -e tmp/`basename $f .svg`.png
done
montage tmp/*.png -tile 5x sign.png
rm -rf tmp
