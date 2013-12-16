#!/bin/bash
set -eu

PA_DIR=`cygpath 'C:\Program Files (x86)\Steam\steamapps\common\Planetary Annihilation'`
TARGET_DIR="../pa-versions"

function json-reformat() {
    local file="$1"
    local content=`python -m json.tool "$file"`
    echo "$content" > "$file"
}

# Initialize target directory
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    (cd "$TARGET_DIR"; git init; touch version.txt)
fi

SAVED_VERSION=`cat "$TARGET_DIR/version.txt"`
CURRENT_VERSION=`cat "$PA_DIR/version.txt"`

# Has a new version been released?
if [ "$SAVED_VERSION" = "$CURRENT_VERSION" ]; then
    echo "Already up to date. Current version is $CURRENT_VERSION"
    exit 0
fi

# Save the current version
cd "$TARGET_DIR"
rm -r *
rsync --verbose --archive --prune-empty-dirs \
	--exclude='Coherent/*' \
	--exclude='media/ui/mods/*' \
	--include='*.txt' \
	--include='*.json' \
	--include='*.js' \
	--include='*.html' \
	--include='*.css' \
	--include='*.ini' \
	--filter='hide,! */' \
	"$PA_DIR/" .
for path in `find . -name '*.json'`; do
    echo "Reformatting $path"
    json-reformat "$path"
done
git add -A
git commit -m "v.$CURRENT_VERSION"
