#!/usr/bin/env bash

set -x

for dir in $*;do (
    cd $dir
    test -d data || return
    cd data
    test -e mets.xml || return
    sed -i 's|MIMETYPE="image/jpeg" ID="OCR-D-GT-SEG|MIMETYPE="application/vnd.prima.page+xml" ID="OCR-D-GT-SEG|' mets.xml
    for page in $(ocrd workspace find -k pageId | sort -u);do
        img=$(ocrd workspace find -G OCR-D-IMG -g $page -k local_filename)
        for file in $(ocrd workspace find -G OCR-D-GT-SEG-PAGE -g $page -k local_filename) $(ocrd workspace find -G OCR-D-GT-SEG-BLOCK -g $page -k local_filename)
            do sed -i "s|imageFilename=\"[^\"]*\"|imageFilename=\"$img\"|" $file
        done
    done
) done
