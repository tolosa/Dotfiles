#!/bin/zsh
# Resize a PNG while preserving its aspect ratio, then add transparent margins.
emulate -R zsh
setopt errexit nounset pipefail

usage() {
  cat <<'EOF'
Usage: resize.zsh INPUT.png -o OUTPUT.png [options]

  -o, --output FILE       Target PNG filename (required)
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
                          put any remaining input filename after this

Dimensions and margins are whole pixels. Dimensions must be positive;
margins may be zero. With both dimensions, the image fits inside that box
without cropping or stretching. With one dimension, the other scales
proportionally. Upscaling is allowed. Without dimensions, keep the image size.
Margins are added AFTER resizing, increasing the final output dimensions.
Per-side margins override --margin regardless of option order.
The output directory must already exist. Relative paths use the current directory.

Examples:
  resize.zsh logo.png -o small.png --width 256
  resize.zsh logo.png -o padded.png -w 256 -h 256 --margin 16
  resize.zsh logo.png -o padded.png -w 256 -m 16 --margin-bottom 32 -f
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
      (( $# >= 2 )) || fail "$1 requires a filename"
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
      [[ -z $input && $# == 1 ]] || fail 'Expected exactly one input PNG'
      input=$1
      shift
      ;;
    -*) fail "Unknown option: $1 (see --help)" ;;
    *)
      [[ -z $input ]] || fail 'Expected exactly one input PNG'
      input=$1
      shift
      ;;
  esac
done

[[ -n $input && -n $output ]] || { usage >&2; exit 1; }
[[ ${output:e:l} == png ]] || fail 'Output filename must end in .png'
input=${input:a}
output=${output:a}
[[ ! -d $output ]] || fail "Output is a directory: $output"
if [[ -e $output || -L $output ]] && (( ! overwrite )); then
  print -r -- "Skipped existing target: $output"
  exit 0
fi
[[ -f $input && -r $input ]] || fail "Cannot read input: $input"
[[ -d ${output:h} ]] || fail "Output directory does not exist: ${output:h}"
(( $+commands[magick] )) || fail 'ImageMagick is required; install it with: brew install imagemagick'

top=${top:-$margin}
right=${right:-$margin}
bottom=${bottom:-$margin}
left=${left:-$margin}
typeset -a resize_args
resize_args=()
if [[ -n $width || -n $height ]]; then
  resize_args=(-resize "${width}x${height}")
fi

# Reading from stdin also handles filenames with ImageMagick special characters.
magick PNG:- "${resize_args[@]}" +repage -alpha set -background none \
  -gravity northwest -splice "${left}x${top}" \
  -gravity southeast -splice "${right}x${bottom}" \
  +repage "PNG:$output" < "$input"

print -r -- "Created: $output"
