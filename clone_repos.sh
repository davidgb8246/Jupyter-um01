#!/usr/bin/env bash
set -e
set -o pipefail

TARGET_DIR="/home/jupyter/work"
TEMP_DIR_BASE="/tmp/git_temp"

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
    STATE_FILE="$DEST/.sync_state"

    if [ -d "$DEST/.git" ]; then
        echo "DEBUG: Repository $NAME already exists, checking remote commit."

        cd "$DEST"

        # Fetch remote changes quietly
        git fetch origin --quiet

        LOCAL_HASH=$(git rev-parse HEAD)
        REMOTE_HASH=$(git rev-parse origin/$(git symbolic-ref --short HEAD))

        if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
            echo "DEBUG: Repository $NAME is up to date. No changes."
            continue
        fi

        echo "DEBUG: Repository $NAME has changes. Syncing with temporary clone."

        TEMP_DIR="$TEMP_DIR_BASE/$NAME"
        rm -rf "$TEMP_DIR"
        git clone --quiet "$REPO" "$TEMP_DIR"

        mkdir -p "$(dirname "$STATE_FILE")"
        touch "$STATE_FILE"

        # === ADD / UPDATE FILES ===
        while IFS= read -r -d '' temp_file; do
            rel_path="${temp_file#$TEMP_DIR/}"
            local_file="$DEST/$rel_path"
            mkdir -p "$(dirname "$local_file")"

            now=$(date +%s)

            if [ -f "$local_file" ]; then
                local_hash=$(sha256sum "$local_file" | awk '{print $1}')
                temp_hash=$(sha256sum "$temp_file" | awk '{print $1}')

                if [ "$local_hash" = "$temp_hash" ]; then
                    continue
                fi

                # Determine if file was modified by user since last script update
                if grep -Eq "\|$rel_path\$" "$STATE_FILE" 2>/dev/null; then
                    script_time=$(grep -F "|$rel_path" "$STATE_FILE" | tail -n1 | cut -d'|' -f1)
                    file_time=$(stat -c %Y "$local_file")
                else
                    # File never managed by script → treat as user-modified
                    script_time=0
                    file_time=$(stat -c %Y "$local_file")
                fi

                if [[ "$rel_path" == .git/* ]] || [ "$file_time" -le "$script_time" ]; then
                    cp "$temp_file" "$local_file"
                    # Only update .sync_state for non-.git files
                    if [[ "$rel_path" != .git/* ]]; then
                        sed -i "\|$rel_path|d" "$STATE_FILE"
                        echo "$now|$rel_path" >> "$STATE_FILE"
                    fi
                    [[ "$rel_path" != .git/* ]] && [[ "$rel_path" != ".sync_state" ]] && echo "DEBUG: Updated file: $rel_path"
                else
                    [[ "$rel_path" != .git/* ]] && [[ "$rel_path" != ".sync_state" ]] && echo "DEBUG: Preserved local modification: $rel_path"
                fi
            else
                cp "$temp_file" "$local_file"
                sed -i "\|$rel_path|d" "$STATE_FILE"
                echo "$now|$rel_path" >> "$STATE_FILE"
                [[ "$rel_path" != .git/* ]] && [[ "$rel_path" != ".sync_state" ]] && echo "DEBUG: Added new file: $rel_path"
            fi
        done < <(find "$TEMP_DIR" -type f -print0)

        # === DELETE FILES REMOVED UPSTREAM ===
        while IFS= read -r -d '' local_file; do
            rel_path="${local_file#$DEST/}"

            # Skip sync state file
            if [ "$rel_path" = ".sync_state" ]; then
                continue
            fi

            # Skip files that still exist upstream
            if [ -f "$TEMP_DIR/$rel_path" ]; then
                continue
            fi

            # If script never managed this file → preserve
            if ! grep -Eq "\|$rel_path\$" "$STATE_FILE" 2>/dev/null; then
                [[ "$rel_path" != .git/* ]] && echo "DEBUG: Preserved user file not in upstream: $rel_path"
                continue
            fi

            script_time=$(grep -F "|$rel_path" "$STATE_FILE" | tail -n1 | cut -d'|' -f1)
            file_time=$(stat -c %Y "$local_file")

            if [ "$file_time" -le "$script_time" ]; then
                rm -f "$local_file"
                sed -i "\|$rel_path|d" "$STATE_FILE"
                [[ "$rel_path" != .git/* ]] && [[ "$rel_path" != ".sync_state" ]] && echo "DEBUG: Deleted file removed upstream: $rel_path"
            else
                [[ "$rel_path" != .git/* ]] && [[ "$rel_path" != ".sync_state" ]] && echo "DEBUG: Preserved locally modified file not in upstream: $rel_path"
            fi
        done < <(find "$DEST" -type f -print0)

        rm -rf "$TEMP_DIR"

    else
        echo "DEBUG: Cloning $REPO into $DEST"
        git clone "$REPO" "$DEST"

        cd "$DEST"
        STATE_FILE="$DEST/.sync_state"
        now=$(date +%s)
        touch "$STATE_FILE"

        # Register all files as script-managed
        while IFS= read -r -d '' f; do
            rel_path="${f#$DEST/}"
            # Skip .git files and .sync_state itself
            if [[ "$rel_path" != ".sync_state" ]] && [[ "$rel_path" != .git/* ]]; then
                echo "$now|$rel_path" >> "$STATE_FILE"
            fi
        done < <(find "$DEST" -type f -print0)
    fi
done
