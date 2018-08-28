#!/bin/sh

OPTIND=1
nb=0
lang="fr"
width=128
tile=5
fontsize=16

while getopts "h?n:l:w:t:s:" opt; do
    case "$opt" in
    h|\?)
        echo usage: $0 -n number -l lang -w width -t nb tiles -s fontsize
        exit 0
        ;;
    n)  nb=$OPTARG
        ;;
    l)  lang=$OPTARG
        ;;
    w)  width=$OPTARG
        ;;
    t)  tile=$OPTARG
        ;;
    s)  fontsize=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "export signs... processing"
echo " + (lang: $lang) (number: $nb)"

if [ ! -f "data/$lang.txt" ] ; then
	echo " + ERROR: data/$lang.txt is unknown"
	exit 1
fi

# GET THE SIGNS TO EXPORT

cpt=0
rm -f t_1.txt
touch t_1.txt
for f in `ls -1t res/img/*/*` ; do
	name=`basename $f .svg`
	line=`grep $name "data/$lang.txt"`
	if [ `echo $line | wc -c` -gt 1 ] ; then
		if [ ! $nb -eq 0 ] ; then cpt=$((cpt+1)); fi
		if [ $cpt -le $nb ] ; then
			echo $line >> t_1.txt
		fi
	else
		echo " + INFO: $f is not referenced in data/$lang.txt"
	fi
done

# SORT THE SIGN LIST

sort t_1.txt > t_2.txt
rm -f t_1.txt
echo " + exporting `cat t_2.txt | wc -l` signs"

# EXPORT SIGNS

if [ ! -d "tmp" ] ; then mkdir tmp ; fi
rm -rf tmp/*

cmd=""
while IFS= read -r l; do
	label=`echo $l | sed -e "s/\([^ ]\+\) .*/\1/g"`
	file=`echo $l | sed -e "s/[^|]*| \([^ ]\+\) .*/\1/g"`
	name=`echo $file | sed -e "s|[^/]*/\(.*\)|\1|g"`
	echo " + processing $label: $file (${width}x${width})"
	inkscape res/img/$file.svg -w $width -h $width -e tmp/$name.png
	cmd="$cmd -label $label tmp/$name.png"
done < "t_2.txt"

echo " + building sign.png"
montage$cmd -tile ${tile}x -pointsize $fontsize sign.png


rm -f t_2.txt
rm -rf tmp

