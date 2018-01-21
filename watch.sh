set -euo pipefail

# Project root directory without slash at the end.
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# TODO: Share it with sassc script.
SCSS_DIR="$ROOT/themes/hugo-split-theme/sass"

HUGO_BINARY="hugo"
FSWATCH_BINARY="fswatch"

# Kill all background processes in the current process group on exit (ctrl+C).
trap 'kill 0' EXIT

# Run hugo in the background. It automatically rebuilds the site on any css changes.
"$HUGO_BINARY" server -s "$ROOT" --quiet --disableFastRender &

# sassc input.
SASSC_INPUT_SCSS="$SCSS_DIR/split.scss"
# sassc output
SASSC_OUTPUT_CSS="$SCSS_DIR/../static/assets/css/split.css"
# One of: nested, expanded, compact, compressed.
OUTPUT_CSS_FORMAT="nested"

SASSC_CMD="sassc --style $OUTPUT_CSS_FORMAT $SASSC_INPUT_SCSS $SASSC_OUTPUT_CSS"

# Simple sound in case of sassc compilation error.
SASSC_FAILED_COMMAND="echo -ne Failed to compile sassc\a\a"  # 2 beeps/bells in case of error.

# Small helper.
rebuildCSS() {
  # Do not stop after sassc returned error, because it can be caused by invalid scss syntax.
  $SASSC_CMD || $SASSC_FAILED_COMMAND
}

# Build css.
$SASSC_CMD && echo "Successfully compiled $SASSC_OUTPUT_CSS"

echo "Monitoring $SCSS_DIR dir for file changes."
"$FSWATCH_BINARY" -0 -r -l 0.1 "$SCSS_DIR" | while IFS= read -r -d '' CHANGED_FILE
do
  # Display relative path instead of absolute one.
  CHANGED_FILE=${CHANGED_FILE#$PWD/}
  echo "Rebuilding from $SCSS_DIR due to changed file: $CHANGED_FILE"
  rebuildCSS
done

# Wait for all background processes to complete.
wait
