#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: kindle-show [-l] [-n] FILE
       kindle-show [-l] [-n] - TYPE

Show a file on the Kindle's e-ink screen. FILE can be .md, .html, .txt,
.pdf, or an image. Use - to read from stdin, with TYPE as one of those.

Options:
  -l, --landscape   turn the page sideways
  -n, --no-flash    skip the black-white flash; faster, but old images can ghost
  -r, --release     give the screen back to the Kindle
  -h, --help        show this help

Examples:
  kindle-show notes.md
  kindle-show -l slide.pdf
  echo "build passed" | kindle-show - txt
EOF
}

width=600 height=800 rotate=0 flash=yes
while [[ ${1:-} == -?* ]]; do
  case $1 in
    -h | --help) usage; exit ;;
    -l | --landscape) width=800 height=600 rotate=90 ;;
    -n | --no-flash) flash=no ;;
    -r | --release)
      ssh kindle 'PATH=$PATH:/usr/sbin:/sbin
        rm -f /tmp/kindle-show
        lipc-set-prop com.lab126.powerd preventScreenSaver 0
        /etc/init.d/framework start' >/dev/null
      exit
      ;;
    *) usage >&2; exit 1 ;;
  esac
  shift
done
[[ $# -gt 0 ]] || { usage >&2; exit 1; }

file=$1
type=${2:-${file##*.}}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [[ $file == - ]]; then
  cat >"$tmp/input"
  file=$tmp/input
fi

# 1. Sort the input into HTML, PDF, or image.
case $type in
  md) cmark --unsafe "$file" >"$tmp/page.html" && html=$tmp/page.html ;;
  txt) { echo '<pre style="white-space: pre-wrap">'; sed 's/&/\&amp;/g; s/</\&lt;/g' "$file"; echo '</pre>'; } >"$tmp/page.html" && html=$tmp/page.html ;;
  html | htm) html=$file ;;
  pdf) pdf=$file ;;
  *) image=$file ;;
esac

# 2. HTML -> PDF page the size of the screen.
if [[ -v html ]]; then
  echo "@page { size: ${width}px ${height}px; margin: 0 }" >"$tmp/page.css"
  weasyprint -e utf-8 -s "$tmp/page.css" "$html" "$tmp/page.pdf"
  pdf=$tmp/page.pdf
fi

# 3. First page of the PDF -> image.
if [[ -v pdf ]]; then
  pdftoppm -png -singlefile -scale-to 800 "$pdf" "$tmp/page"
  image=$tmp/page.png
fi

# 4. Fit, rotate, and save as the 8-bit greyscale PNG eips draws.
magick "${image}[0]" -background white -flatten \
  -resize "${width}x${height}" -gravity center -extent "${width}x${height}" -rotate "$rotate" \
  -colorspace Gray -define png:color-type=0 -define png:bit-depth=8 "$tmp/screen.png"

# 5. Send and draw. Once per Kindle boot, stop the screensaver and stock UI.
#    (SSH commands get a minimal PATH; eips is in /usr/sbin.) "flash=..." is
#    joined onto the start of the Kindle-side script, setting a variable there.
ssh kindle "flash=$flash" 'PATH=$PATH:/usr/sbin:/sbin
  cat >/tmp/screen.png
  if [ ! -e /tmp/kindle-show ]; then
    lipc-set-prop com.lab126.powerd preventScreenSaver 1
    /etc/init.d/framework stop
    sleep 2
    touch /tmp/kindle-show
  fi
  if [ "$flash" = yes ]; then eips -c; fi
  eips -g /tmp/screen.png' <"$tmp/screen.png" >/dev/null
