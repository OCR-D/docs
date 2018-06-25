_cut_version () { read firstline; echo "${firstline## }"; }
_old_tess_version=$(tesseract --version|_cut_version)

PATH="/usr/bin:$PATH"
TESSDATA_PREFIX="/usr/share/tesseract-ocr/4.00/tessdata"

echo "$PATH"

[[ -n "$VIRTUAL_ENV" ]] && PATH="$VIRTUAL_ENV/bin:$PATH"

echo "Switched from '${_old_tess_version}' to '$(tesseract --version|_cut_version). TESSDATA_PREFIX=$TESSDATA_PREFIX"
