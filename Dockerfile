# Base com CUDA 12.6
FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Informações do sistema
RUN nvidia-smi && lsb_release -a && uname -m

# Dependências básicas
RUN apt update && apt install -y \
    software-properties-common \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt update && \
    apt install -y python3.11 python3.11-distutils python3.11-venv && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    python3 --version && \
    python3 -m ensurepip --upgrade && \
    python3 -m pip install --upgrade pip

# CUDA Toolkit
RUN wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda_12.6.0_560.28.03_linux.run && \
    sh cuda_12.6.0_560.28.03_linux.run --toolkit --silent --override && \
    echo 'export PATH=/usr/local/cuda-12.6/bin:$PATH' >> ~/.bashrc && \
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# cuDNN 9.0
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb && \
    dpkg -i cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb && \
    cp /var/cudnn-local-repo-ubuntu2004-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get install -y cudnn9-cuda-12 && \
    rm cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb

# cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb && \
    dpkg -i cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb && \
    cp /var/cusparselt-local-repo-ubuntu2004-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get install -y libcusparselt0 libcusparselt-dev && \
    ldconfig && \
    rm cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb

# Biblioteca uv
RUN pip install uv

# Projeto DIA
RUN git clone https://github.com/nari-labs/dia.git
WORKDIR /dia
RUN uv venv --python python3.11

# Comando default
CMD ["uv", "run", "app.py"]
