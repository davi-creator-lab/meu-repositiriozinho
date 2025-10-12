# ==============================
# NARI LABS DIA Dockerfile
# Base: Ubuntu 22.04 + CUDA 12.6
# ==============================

FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

# Evitar perguntas interativas
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/cuda-12.6/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH

# Atualizar pacotes e instalar dependências básicas
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl wget git unzip sudo build-essential \
    lsb-release ca-certificates gnupg \
    python3.11 python3.11-venv python3.11-distutils python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11

# Atualizar pip
RUN python3 -m pip install --upgrade pip

# Instalar cuDNN 9
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && dpkg -i cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && cp /var/cudnn-local-repo-ubuntu2204-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcudnn9 libcudnn9-dev \
    && rm cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb

# Instalar cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && dpkg -i cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && cp /var/cusparselt-local-repo-ubuntu2204-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcusparselt0 libcusparselt-dev \
    && rm cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb

# Atualizar cache de bibliotecas
RUN ldconfig

# Instalar UV
RUN pip install uv

# Clonar repositório DIA
RUN git clone https://github.com/nari-labs/dia.git /dia

WORKDIR /dia

# Criar ambiente virtual com Python 3.11
RUN uv venv --python python3.11

# Entrypoint
CMD ["uv", "run", "app.py"]
