#!/bin/zsh
# Resize PNGs in a folder while preserving aspect ratios, then add transparent margins.
emulate -R zsh
setopt errexit nounset pipefail

usage() {
  cat <<'EOF'
Usage: resize.zsh SOURCE_DIR -o OUTPUT_DIR [options]

  -o, --output DIR        Target folder (required; created if missing)
  -w, --width PIXELS      Maximum image width before margins
  -h, --height PIXELS     Maximum image height before margins
  -m, --margin PIXELS     Transparent margin on all sides (default: 0)
      --margin-top N     Override the top margin
      --margin-right N   Override the right margin
      --margin-bottom N  Override the bottom margin
      --margin-left N    Override the left margin
  -f, --overwrite         Replace an existing target (otherwise skip)
      --help              Show this help
      --                  End options (for input names starting with '-');
                          put the source folder after this

Dimensions and margins are whole pixels. Dimensions must be positive;
margins may be zero. With both dimensions, the image fits inside that box
without cropping or stretching. With one dimension, the other scales
proportionally. Upscaling is allowed. Without dimensions, keep the image size.
Margins are added AFTER resizing, increasing the final output dimensions.
Per-side margins override --margin regardless of option order.
Process all PNG files directly in the source folder (including .PNG and hidden
files), keeping their filenames. Subfolders and non-PNG files are ignored.
Existing target files are skipped unless --overwrite is passed.
Relative paths use the current directory.

Examples:
  resize.zsh source -o small --width 256
  resize.zsh source -o padded -w 256 -h 256 --margin 16
  resize.zsh source -o padded -w 256 -m 16 --margin-bottom 32 -f
EOF
}

fail() {
  print -u2 -r -- "Error: $*"
  exit 1
}

input=''
output=''
width=''
height=''
margin=0
top=''
right=''
bottom=''
left=''
overwrite=0

while (( $# )); do
  case $1 in
    --help) usage; exit 0 ;;
    -f|--overwrite) overwrite=1; shift ;;
    -o|--output)
      (( $# >= 2 )) || fail "$1 requires a folder"
      output=$2
      shift 2
      ;;
    -w|--width|-h|--height|-m|--margin|--margin-top|--margin-right|--margin-bottom|--margin-left)
      (( $# >= 2 )) || fail "$1 requires a pixel value"
      [[ $2 == <-> && ${#2} -le 9 ]] || fail "$1 requires a nonnegative integer of at most 9 digits"
      value=$(( 10#$2 ))
      case $1 in
        -w|--width|-h|--height)
          (( value > 0 )) || fail "$1 must be greater than zero"
          ;;
      esac
      case $1 in
        -w|--width) width=$value ;;
        -h|--height) height=$value ;;
        -m|--margin) margin=$value ;;
        --margin-top) top=$value ;;
        --margin-right) right=$value ;;
        --margin-bottom) bottom=$value ;;
        --margin-left) left=$value ;;
      esac
      shift 2
      ;;
    --)
      shift
      (( $# == 0 )) && break
      [[ -z $input && $# == 1 ]] || fail 'Expected exactly one source folder'
      input=$1
      shift
      ;;
    -*) fail "Unknown option: $1 (see --help)" ;;
    *)
      [[ -z $input ]] || fail 'Expected exactly one source folder'
      input=$1
      shift
      ;;
  esac
done

[[ -n $input && -n $output ]] || { usage >&2; exit 1; }
input=${input:a}
output=${output:a}
[[ -d $input && -r $input && -x $input ]] || fail "Cannot read source folder: $input"
(( $+commands[magick] )) || fail 'ImageMagick is required; install it with: brew install imagemagick'
mkdir -p -- "$output"

top=${top:-$margin}
right=${right:-$margin}
bottom=${bottom:-$margin}
left=${left:-$margin}
typeset -a resize_args images
resize_args=()
if [[ -n $width || -n $height ]]; then
  resize_args=(-resize "${width}x${height}")
fi

images=("$input"/*.[pP][nN][gG](ND.))
if (( $#images == 0 )); then
  print -r -- "No PNG images found in: $input"
  exit 0
fi

for file in "${images[@]}"; do
  target="$output/${file:t}"
  if [[ -e $target || -L $target ]] && (( ! overwrite )); then
    print -r -- "Skipped existing target: $target"
    continue
  fi
  [[ ! -d $target ]] || fail "Target is a directory: $target"

  # Reading from stdin also handles filenames with ImageMagick special characters.
  magick PNG:- "${resize_args[@]}" +repage -alpha set -background none \
    -gravity northwest -splice "${left}x${top}" \
    -gravity southeast -splice "${right}x${bottom}" \
    +repage "PNG:$target" < "$file"

  print -r -- "Created: $target"
done
