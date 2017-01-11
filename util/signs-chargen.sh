#!/bin/bash

# Simple font generator for homedecor signs mod
# By Vanessa Ezekowitz
#
# License:  WTFPL

# Usage:
#
# signs-chargen.sh fontname fontheight [top-excess bottom-excess left-excess right-excess]
#
# font is the standard X11 font spec, in quotes, such as:
# "-*-helvetica-*-r-*-*-12-*-*-*-*-*-*-*"
#
# Note that top+bottom excess can easily exceed the specified font size.  The excess values
# must all be specified if any are.

textfont=$1
fontheight=$2
texcess=$3
bexcess=$4
lexcess=$5
rexcess=$6

pagesize="-size \"$((fontheight*2))x$((fontheight*4))\" xc:none"
cmdbase="convert $pagesize -font \"$textfont\" -gravity North -pointsize $fontheight "
trimargs1="+repage -gravity West -background red -splice 1x0 -background green -splice 1x0 -trim  +repage -chop 1x0"
trimargs2="+repage -gravity East -background red -splice 1x0 -background green -splice 1x0 -trim  +repage -chop 1x0"

choptopbottom="-gravity North -chop 0x"$texcess" -gravity South -chop 0x"$bexcess
chopsides="-gravity West -chop "$lexcess"x0 -gravity East -chop "$rexcess"x0"


# numbers require a slightly different command:

for charcode in `seq 48 57`; do
	char=$(printf \\$(printf "%o" $charcode))
	hexcode=$(echo -n "$char" |xxd -ps)
	command=$cmdbase" -annotate 0 \"$char\" hdf_"$hexcode".png"
	echo "$char : $hexcode"
	eval $command
done

# then the rest of the ascii set, except there are a few we have to skip

for charcode in 32 `seq 35 47` `seq 58 91` 93 94 95 `seq 97 126`; do
	char=$(printf \\$(printf "%o" $charcode))
	hexcode=$(echo -n "$char" |xxd -ps)
	command="$cmdbase -draw \"text 0,0 $char\" hdf_"$hexcode".png"
	echo "$char : $hexcode"
	eval "$command"
done

# those special cases are ! " * \ `

command="$cmdbase -annotate 0 \! hdf_21.png"
echo "! : 21"
eval $command

command="$cmdbase -annotate 0 \\\" hdf_22.png"
echo "\" : 22"
eval $command

command="$cmdbase -annotate 0 \* hdf_2a.png"
echo "* : 2a"
eval $command

command="$cmdbase -annotate 0 \\\\\\\\ hdf_5c.png"
echo "\\ : 5c"
eval $command

command="$cmdbase -annotate 0 \\\` hdf_60.png"
echo "\` : 60"
eval $command

if [ -z "$trimargs1" ] ; then 
	for i in `ls *.png`; do
		mogrify +repage $choptopbottom $chopsides $i
	done
else
	for i in `ls *.png`; do
		convert $i $trimargs1 XXXXX$i
		mv XXXXX$i $i
		convert $i $trimargs2 XXXXX$i
		mv XXXXX$i $i
		convert $i $choptopbottom $chopsides XXXXX$i
		mv XXXXX$i $i
	done
fi

convert -size $(((fontheight/2)+1))x$((fontheight*4)) xc:none $choptopbottom $chopsides hdf_20.png

