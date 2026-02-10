# ==========================================
# Image: jupyter-um01:sage-statistics-v0.1.1 / jupyter-um01:latest
# Description:
#   - Sage and Statistics environment
#   - JupyterLab with authentication
# Contains:
#   - JupyterLab
#   - SageMath (Python 3.12)
#   - Statistics Kernel (Python 3.11): numpy, pandas, scipy, seaborn, matplotlib, pillow, empiricaldist
#   - clone_repos.sh script support
# ==========================================


# Base image
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/conda/bin:$PATH"
ENV JUPYTER_PASSWD=""
ENV GIT_REPOS=""

# -----------------------------
# Runtime system dependencies only
# -----------------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    wget \
    curl \
    bzip2 \
    git \
    ca-certificates \
    sudo \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Miniconda
# -----------------------------
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
 && bash /tmp/miniconda.sh -b -p /opt/conda \
 && rm /tmp/miniconda.sh \
 && conda clean -afy \
 && conda config --add channels conda-forge \
 && conda config --set channel_priority strict \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# -----------------------------
# Sage environment
# -----------------------------
RUN conda create -y -n sage \
    python=3.12 \
    sage \
    jupyterlab \
    ipykernel \
 && conda clean -afy

# -----------------------------
# Statistics environment
# -----------------------------
RUN conda create -y -n statistics \
    python=3.11 \
    ipykernel \
    numpy \
    pandas \
    scipy \
    seaborn \
    matplotlib \
    pillow \
    empiricaldist \
    -c conda-forge \
 && conda run -n statistics python -m ipykernel install \
    --name statistics \
    --display-name "Statistics" \
 && conda clean -afy

EXPOSE 8888
WORKDIR /home/jupyter/work

COPY clone_repos.sh /usr/local/bin/clone_repos.sh
RUN chmod +x /usr/local/bin/clone_repos.sh

# -----------------------------
# Start JupyterLab
# -----------------------------
CMD ["bash","-c","/usr/local/bin/clone_repos.sh && exec conda run --no-capture-output -n sage sage -python -m jupyterlab --ip=0.0.0.0 --no-browser --allow-root --notebook-dir=/home/jupyter/work $( [ -n \"$JUPYTER_PASSWD\" ] && echo \"--ServerApp.password=$(conda run -n sage sage -python -c 'from jupyter_server.auth import passwd; print(passwd(\"'$JUPYTER_PASSWD'\"))')\" || echo \"--ServerApp.token= --ServerApp.password=\" )"]
