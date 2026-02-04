cd "$HOME"

docker run -d \
  --rm \
  -p 7777:8888 \
  -e GIT_REPOS="${GIT_REPOS:-https://github.com/jmalmira/statistics}" \
  -v "$(pwd)/mi_trabajo:/home/jupyter/work" \
  --name jupyter-stats \
  davidgb8246/jupyter-um01:statistics-v0.1
