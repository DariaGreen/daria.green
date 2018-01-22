#!/bin/bash
set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCSS_DIR="$ROOT/themes/hugo-split-theme/sass"

HUGO="hugo"
if [ `which sass` ]; then
  SASS=sass
elif [ `which sassc` ]; then
  SASS=sassc
else
  echo "Sass is not installed" && exit 1
fi

# Compile sass
"$SASS" themes/hugo-split-theme/sass/split.scss themes/hugo-split-theme/static/assets/css/split.css

# Build site
"$HUGO"
