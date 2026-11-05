#!/usr/bin/env bash
# kindle-show: draw a file on the Kindle's 600x800 screen.
#
#   kindle-show FILE        type comes from the extension: md, html, txt, pdf, or an image
#   kindle-show - TYPE      read from stdin, e.g.  echo hello | kindle-show - txt
#   kindle-show --release   give the screen back to the Kindle's own UI
set -euo pipefail

if [[ ${1:-} == --release ]]; then
  ssh kindle 'PATH=$PATH:/usr/sbin:/sbin
    rm -f /tmp/kindle-show
    lipc-set-prop com.lab126.powerd preventScreenSaver 0
    /etc/init.d/framework start' >/dev/null
  exit
fi

file=${1:?usage: kindle-show FILE [TYPE]}
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

# 2. Lay out HTML on a PDF page exactly the size of the screen.
if [[ -v html ]]; then
  echo '@page { size: 600px 800px; margin: 0 }' >"$tmp/page.css"
  weasyprint -e utf-8 -s "$tmp/page.css" "$html" "$tmp/page.pdf"
  pdf=$tmp/page.pdf
fi

# 3. Turn the first page of the PDF into an image.
if [[ -v pdf ]]; then
  pdftoppm -png -singlefile -scale-to 800 "$pdf" "$tmp/page"
  image=$tmp/page.png
fi

# 4. Fit it to the screen as an 8-bit greyscale PNG, the format eips draws.
magick "${image}[0]" -background white -flatten \
  -resize 600x800 -gravity center -extent 600x800 \
  -colorspace Gray -define png:color-type=0 -define png:bit-depth=8 "$tmp/screen.png"

# 5. Send it and draw it. The first time after each Kindle boot, also stop the
#    screensaver and the Kindle's own UI so nothing draws over us. SSH commands
#    get a minimal PATH on the Kindle, so add /usr/sbin, where eips lives.
ssh kindle 'PATH=$PATH:/usr/sbin:/sbin
  cat >/tmp/screen.png
  if [ ! -e /tmp/kindle-show ]; then
    lipc-set-prop com.lab126.powerd preventScreenSaver 1
    /etc/init.d/framework stop
    sleep 2
    touch /tmp/kindle-show
  fi
  eips -c
  eips -g /tmp/screen.png' <"$tmp/screen.png" >/dev/null
