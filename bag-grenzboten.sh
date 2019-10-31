#!/usr/bin/env bash

set -e

mets_path="$1"

if [[ -z "$mets_path" || ! -r "$mets_path" ]];then
    echo "Usage: $0 PATH_TO_METS"
    exit 1
fi

mets_path="$(realpath "$mets_path")"
mets_dir="$(dirname "$mets_path")"
cd "$mets_dir"

replace_filegroups () {
    echo "# Normalizing fileGrp USE"
    sed -i 's,fulltext FR,OCR-D-SEG-ZOT,' "$mets_path"
    sed -i 's,master image,OCR-D-IMG,' "$mets_path"
}

replace_xml_jpg_xml () {
    echo "# Replace '*.xml' with '*.jpg.xml' in $mets_path"
    sed -i 's/\/\([0-9]*\)\.xml"/\/\1.jpg.xml"/g' $mets_path
}

replace_tif_jpg () {
    echo "# Replace '*.tif' with '*.jpg' in $mets_path"
    sed -i 's/\.tif"/.jpg"/g' $mets_path
    sed -i 's,image/tiff,image/jpeg,g' $mets_path
}

rename_xlink_href () {
    echo "# Determining replacements in $mets_path"
    replacement_file="replacements.txt"
    printf "" > "$replacement_file"
    xmlstarlet sel -t -v '//*[local-name()="FLocat"]/@*[local-name()="href"]' "$mets_path"|{
        while read cand;do
            local subdir="${cand%/*}"
            local basename="${cand##*/}"
            echo find "$mets_dir" -name "$basename"
            local actual_path="$(find -name "$basename")"
            actual_path="${actual_path#./}"
            printf "\"$cand\":\"$actual_path\"\n" >> "$replacement_file"
            printf "."
            # echo "s,$cand,$actual_path,"
            # sed -i "s,$cand,$actual_path," "$mets_path"
        done
        printf "\n# Replacing with sed magic\n"
        # https://unix.stackexchange.com/questions/269368/string-replacement-using-a-dictionary
        sed '
s|"\(.*\)"[[:blank:]]*:[[:blank:]]*"\(.*\)"|\1\
\2|
h
s|.*\n||
s|[\&/]|\\&|g
x
s|\n.*||
s|[[\.*^$/]|\\&|g
G
s|\(.*\)\n\(.*\)|s/\1/\2/g|
            ' "$replacement_file" | sed -f - -i "$mets_path"
    }
    rm "$replacement_file"
}

prune_files () {
    echo "# Removing non-existent files from $mets_path"
    ocrd workspace prune-files
}


replace_filegroups
replace_tif_jpg
# replace_xml_jpg_xml
rename_xlink_href
prune_files
