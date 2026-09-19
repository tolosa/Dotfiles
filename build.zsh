#!/bin/zsh
# Rename source images, then build the Fastfetch logos at 1000 pixels high.
# Run from the project root: ./build.zsh
emulate -R zsh
setopt errexit nounset pipefail

zsh resources/logos/rename.zsh
zsh resources/logos/resize.zsh resources/logos/source \
  --output fastfecth/dot-config/fastfetch/logos \
  --height 1000 \
  --overwrite
