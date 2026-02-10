#!/usr/bin/env bash

set -o pipefail

echo "INFO: Starting environment..."
cd "$HOME" || exit 10

APP_PORT="${APP_PORT:-7777}"
GIT_REPOS="${GIT_REPOS:-}"
CONTAINER_NAME="${CONTAINER_NAME:-jupyter-sage}"

MAX_RETRIES=15
RETRY_DELAY=2
JUPYTER_URL="http://localhost:${APP_PORT}"
IMAGE_TAG="sage-v0.1.1"
WORK_DIR="$(pwd)/mi_trabajo"

[ -d "$WORK_DIR" ] || mkdir -p "$WORK_DIR" || exit 15

CONTAINER_ID=$(docker run -d \
  --rm \
  -p "${APP_PORT}:8888" \
  -e GIT_REPOS="${GIT_REPOS}" \
  -v "${WORK_DIR}:/home/jupyter/work" \
  --name "${CONTAINER_NAME}" \
  "davidgb8246/jupyter-um01:${IMAGE_TAG}") || {
    echo "ERROR: Docker failed to start the container"
    exit 20
}

echo "INFO: Docker container started: ${CONTAINER_NAME} (ID: ${CONTAINER_ID})"
echo "      > To stop the container, run: docker stop ${CONTAINER_NAME}"
echo -e "      > To view the logs, run: docker logs ${CONTAINER_NAME}\n"

echo "INFO: Starting Jupyter service, please wait..."

for ((i=1; i<=MAX_RETRIES; i++)); do
  curl -sf "${JUPYTER_URL}" >/dev/null && {
    echo "INFO: Jupyter is available on the following addresses:"

    echo "      > http://localhost:${APP_PORT}"
    echo "      > http://127.0.0.1:${APP_PORT}"

    if [[ -n "${SHOW_ALL_IPS}" ]]; then
      for ip in $(hostname -I); do
        [[ $ip != *:* ]] && echo "      > http://${ip}:${APP_PORT}"
      done
    fi

    exit 0
  }
  sleep "${RETRY_DELAY}"
done

echo "Service did not become available. You can try accessing manually:"
echo "  ${JUPYTER_URL}"
exit 30
