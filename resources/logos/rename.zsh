#!/bin/zsh
# macOS: rename recursively by birth time, preserving folders and extensions.
# Usage: zsh resources/logos/rename.zsh [--dry-run]
# Sequence numbers start at 001 for each date across the whole tree.
emulate -R zsh
setopt errexit nounset pipefail

root=${0:A:h}
dry_run=0
case ${1:-} in
  --dry-run) dry_run=1 ;;
  '') ;;
  *) print -u2 'Usage: rename.zsh [--dry-run]'; exit 2 ;;
esac
(( $# <= 1 )) || { print -u2 'Too many arguments'; exit 2; }

typeset -a records sources targets
typeset -A counts moving
for file in "$root"/**/*(ND.); do
  [[ $file == ${0:A} ]] && continue
  birth=$(stat -f '%B' "$file")
  printf -v record '%020d:%s' "$birth" "$file"
  records+=("$record")
done

# Sort oldest first; paths break ties deterministically.
for record in "${(@o)records}"; do
  file=${record#*:}
  day=$(stat -f '%SB' -t '%Y-%m-%d' "$file")
  counts[$day]=$(( ${counts[$day]:-0} + 1 ))
  printf -v name '%s-%03d' "$day" "${counts[$day]}"
  extension=''
  [[ ${file:t} == *.* && ${file:t} != .* ]] && extension=".${file:e}"
  target="${file:h}/$name$extension"
  [[ $file == "$target" ]] && continue
  sources+=("$file")
  targets+=("$target")
  moving[$file]=1
done

# Check every destination before changing anything; never overwrite a file.
for target in "${targets[@]}"; do
  if [[ ( -e $target || -L $target ) && -z ${moving[$target]:-} ]]; then
    print -u2 -r -- "Destination already exists: $target"
    exit 1
  fi
done

for (( i=1; i <= $#sources; i++ )); do
  printf '%s -> %s\n' "${sources[$i]}" "${targets[$i]}"
done
(( dry_run || $#sources == 0 )) && exit 0

# Stage first so existing numbered names can safely exchange places.
staging=$(mktemp -d "$root/.rename.XXXXXXXX")
trap 'print -u2 -r -- "Rename interrupted; remaining files are in $staging"' ZERR
for (( i=1; i <= $#sources; i++ )); do
  mv "${sources[$i]}" "$staging/$i"
done
for (( i=1; i <= $#sources; i++ )); do
  mv -n "$staging/$i" "${targets[$i]}"
done
rmdir "$staging"
