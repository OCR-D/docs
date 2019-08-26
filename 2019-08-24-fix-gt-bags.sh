#!/bin/bash

bags_dir="$1"
if [[ ! -d "$bags_dir" ]];then
    echo "Usage: $0 BAGS_DIR"
    echo ""
    echo "BAGS_DIR should contain unserialized OCRD-ZIP exclusively"
    echo ""
    echo "Script must be in the same repo (OCR-D/docs) as the workspace update and bag validation script"
    exit 1
fi

find "$bags_dir" -type d -mindepth 1 -maxdepth 1 | while read bagdir;do (
    cd "$bagdir";
    python3 ocrd-gt-add-extensions.py .

)
done
