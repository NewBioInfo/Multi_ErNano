#!/bin/bash

# Checking if packages are already installed

## samtools
if dpkg -s "samtools" >/dev/null 2>&1; then
	echo "samtools is already installed"
else
	#Install the package
	echo "Please download latest samtools and install"
fi

## minimap2
if dpkg -s "minimap2" >/dev/null 2>&1; then
	echo "minimap2 is already installed"
else	
	#Install the package
	echo "Installing package minimap2"
	git clone https://github.com/lh3/minimap2
	cd minimap2 && make
fi

## featureCounts
if command -v featureCounts >/dev/null 2>&1; then
    echo "featureCounts is already installed"
else
    echo "Please download latest Subread package and install"
fi

## stringtie2
if dpkg -s "stringtie" >/dev/null 2>&1; then
	echo "stringtie is already installed"
else	
	#Install the package
	echo "Installing package stringtie"
	git clone https://github.com/mpertea/stringtie2
	cd stringtie2
	make release
fi



echo "All installation DONE"