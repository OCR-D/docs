#!/usr/bin/env bash

set -x

for dir in "$@"; do (
    cd "$dir"
    test -d data || return
    cd data
    test -e mets.xml || return
    sed -i 's|MIMETYPE="image/jpeg" ID="OCR-D-GT|MIMETYPE="application/vnd.prima.page+xml" ID="OCR-D-GT|' mets.xml
    for page in $(ocrd workspace find -k pageId | sort -u);do
        img=$(ocrd workspace find -G OCR-D-IMG -g $page -k local_filename)
        for file in $(ocrd workspace find -m application/vnd.prima.page+xml -g $page -k local_filename); do
            test -e $file || continue
            sed -i "s|imageFilename=\"[^\"]*\"|imageFilename=\"$img\"|" $file
        done
    done
) done
