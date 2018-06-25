_cut_version () { read firstline; echo "${firstline## }"; }
_old_tess_version=$(tesseract --version|_cut_version)

export PATH="$HOME/.local/bin:$PATH"
export TESSDATA_PREFIX="$HOME/tess3"

[[ -n "$VIRTUAL_ENV" ]] && source "$VIRTUAL_ENV/bin/activate"

echo "Switched from '${_old_tess_version}' to '$(tesseract --version|_cut_version). TESSDATA_PREFIX=$TESSDATA_PREFIX"
