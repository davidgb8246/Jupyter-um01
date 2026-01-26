# ==========================================
# Image: jupyter-um01:sage-v0.1
# Description:
#   - Sage environment only
#   - JupyterLab with authentication
# Contains:
#   - JupyterLab
#   - SageMath (Python 3.12)
#   - clone_repos.sh script support
# ==========================================


# Base image
FROM ubuntu:22.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/conda/bin:$PATH"
# Set this to enable a password
ENV JUPYTER_PASSWD=""
# Comma-separated list of git repository URLs to clone at startup
ENV GIT_REPOS=""

# -----------------------------
# Install system dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bzip2 \
    git \
    build-essential \
    cmake \
    libssl-dev \
    libffi-dev \
    pkg-config \
    python3-dev \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Miniconda
# -----------------------------
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean --all -y && \
    /opt/conda/bin/conda config --add channels conda-forge && \
    /opt/conda/bin/conda config --set channel_priority strict && \
    /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# -----------------------------
# Sage environment with JupyterLab
# -----------------------------
RUN /opt/conda/bin/conda create -y -n sage python=3.12 sage jupyterlab ipykernel

# Use Sage environment for subsequent commands
SHELL ["conda", "run", "-n", "sage", "/bin/bash", "-c"]

# -----------------------------
# Expose JupyterLab port
# -----------------------------
EXPOSE 8888

# Set default work folder inside the container
WORKDIR /home/jupyter/work

# Copy the clone repositories script into the image
COPY clone_repos.sh /usr/local/bin/clone_repos.sh
RUN chmod +x /usr/local/bin/clone_repos.sh

# -----------------------------
# Start JupyterLab
# -----------------------------
CMD ["bash","-c","/usr/local/bin/clone_repos.sh && if [ -n \"$JUPYTER_PASSWD\" ]; then HASHED_PASSWORD=$(conda run -n sage sage -python -c \"from jupyter_server.auth import passwd; print(passwd('$JUPYTER_PASSWD'))\"); exec conda run --no-capture-output -n sage sage -python -m jupyterlab --ip=0.0.0.0 --no-browser --allow-root --ServerApp.password=$HASHED_PASSWORD --notebook-dir=/home/jupyter/work; else exec conda run --no-capture-output -n sage sage -python -m jupyterlab --ip=0.0.0.0 --no-browser --allow-root --ServerApp.token= --ServerApp.password= --notebook-dir=/home/jupyter/work; fi"]
