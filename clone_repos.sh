#!/usr/bin/env bash
set -e

TARGET_DIR="/home/jupyter/work"

if [ -z "$GIT_REPOS" ]; then
    echo "DEBUG: No GIT_REPOS specified, skipping repository cloning."
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
        echo "DEBUG: Repository $NAME already exists, fetching updates."
        cd "$DEST"

        # Fetch remote state
        git fetch origin

        BRANCH=$(git symbolic-ref --short HEAD)

        # If no new commits upstream, do nothing
        if git diff --quiet HEAD..origin/$BRANCH; then
            echo "DEBUG: Repository $NAME is up to date."
            continue
        fi

        echo "DEBUG: Repository $NAME has upstream changes."

        # Files changed or added upstream (array-safe)
        mapfile -t UPSTREAM_FILES < <(git diff --name-only HEAD..origin/$BRANCH)

        # Files modified locally
        mapfile -t LOCAL_MODIFIED < <(git diff --name-only)

        # Debug: upstream-changed files
        if [ ${#UPSTREAM_FILES[@]} -gt 0 ]; then
            echo "DEBUG: Upstream-changed files:"
            printf "  %s\n" "${UPSTREAM_FILES[@]}"
        else
            echo "DEBUG: No upstream-changed files."
        fi

        # Debug: locally modified files
        if [ ${#LOCAL_MODIFIED[@]} -gt 0 ]; then
            echo "DEBUG: Locally modified files:"
            printf "  %s\n" "${LOCAL_MODIFIED[@]}"
        else
            echo "DEBUG: No locally modified files."
        fi

        # Compute safe files (upstream changed but not locally modified)
        SAFE_FILES=()
        for f in "${UPSTREAM_FILES[@]}"; do
            if ! printf '%s\n' "${LOCAL_MODIFIED[@]}" | grep -Fxq "$f"; then
                SAFE_FILES+=("$f")
            fi
        done

        # Update only safe files
        if [ ${#SAFE_FILES[@]} -gt 0 ]; then
            git checkout origin/$BRANCH -- "${SAFE_FILES[@]}"
            echo "DEBUG: Updated files:"
            printf "  %s\n" "${SAFE_FILES[@]}"
        else
            echo "DEBUG: No files eligible for update (local changes preserved)."
        fi

    else
        echo "DEBUG: Cloning $REPO into $DEST"
        git clone "$REPO" "$DEST"
    fi
done
