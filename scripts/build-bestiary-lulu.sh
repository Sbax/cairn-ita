#!/bin/bash
# This creates the interior files for the lulu print option
# Parameters validation

if [ -z "$1" ]; then
	echo "Usage: build-bestiary-lulu.sh path/to/cairn/dir"
	exit 1
fi

# Directories set up

BASE_DIR=$1

scriptdir="$BASE_DIR/scripts"
sourcedir="$BASE_DIR/risorse/mostri"
tmpdir="$BASE_DIR/tmp"
destdir="$BASE_DIR/build"

if ! [ -x $scriptdir ]; then
	echo "Script directory $scriptdir does not exist"
	exit 1
fi

if ! [ -x $sourcedir ]; then
	echo "Source directory $sourcedir does not exist"
	exit 1
fi

if ! [ -x $tmpdir ]; then
	mkdir $tmpdir
fi

if ! [ -x $destdir ]; then
	mkdir $destdir
fi

if [ -x "$tmpdir/mostri" ]; then
	rm -rf $tmpdir/mostri
fi

mkdir $tmpdir/mostri
currentdate="$(date +%m-%Y)"

rsync -av $sourcedir/ $tmpdir/mostri/
sed -i -f sources/prep.sed $tmpdir/mostri/*.md
cat $tmpdir/mostri/*.md >> $tmpdir/cairn-bestiary-tmp.md
cp sources/lulu.tex $tmpdir/cairn-bestiary.tex
pandoc $tmpdir/cairn-bestiary-tmp.md -f markdown -t latex -o $tmpdir/cairn-bestiary-tmp.tex
cat $tmpdir/cairn-bestiary-tmp.tex >> $tmpdir/cairn-bestiary.tex
sed -i '$a \\\end{document}' $tmpdir/cairn-bestiary.tex
pdflatex -interaction=nonstopmode -output-directory=$tmpdir $tmpdir/cairn-bestiary.tex 
pdflatex -interaction=nonstopmode -output-directory=$tmpdir $tmpdir/cairn-bestiary.tex 
mv $tmpdir/cairn-bestiary.pdf "$destdir/cairn-bestiary-lulu-interior-$currentdate.pdf"
rm -rf $tmpdir