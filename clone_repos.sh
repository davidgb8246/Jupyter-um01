#!/usr/bin/env bash
set -e

TARGET_DIR="/home/jupyter/work"

if [ -z "$GIT_REPOS" ]; then
    echo "No GIT_REPOS specified, skipping repository cloning."
    exit 0
fi

IFS=',' read -ra REPOS <<< "$GIT_REPOS"

for REPO in "${REPOS[@]}"; do
    REPO="$(echo "$REPO" | xargs)"
    if [ -z "$REPO" ]; then
        continue
    fi

    NAME=$(basename "$REPO" .git)
    DEST="$TARGET_DIR/$NAME"

    if [ -d "$DEST/.git" ]; then
        echo "Repository $NAME already exists, skipping."
    else
        echo "Cloning $REPO into $DEST"
        git clone "$REPO" "$DEST"
    fi
done
