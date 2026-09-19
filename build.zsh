#!/bin/zsh
# Rename source images, then build the Fastfetch logos and Ghostty backgrounds.
# Run from the project root: ./build.zsh
emulate -R zsh
setopt errexit nounset pipefail

zsh resources/logos/rename.zsh

zsh resources/logos/resize.zsh resources/logos/source \
  --output fastfecth/dot-config/fastfetch/logos \
  --height 1000 \
  --overwrite

zsh resources/logos/resize.zsh resources/logos/source \
  --output ghostty/dot-config/ghostty/backgrounds \
  --height 1100 \
  --margin-bottom 80 \
  --margin-right 80 \
  --overwrite
