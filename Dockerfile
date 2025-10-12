# =========================================
# Dockerfile: Nari Labs DIA - Ubuntu 22.04 + GPU NVIDIA
# CUDA 12.6 + cuDNN 9.0.0
# =========================================

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar sistema e instalar dependências básicas
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.11 python3.11-distutils python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# 3. Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11

# 4. Instalar pip
RUN python3 -m ensurepip --upgrade \
    && python3 -m pip install --upgrade pip

# 5. Instalar CUDA 12.6 toolkit
RUN wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda_12.6.0_560.28.03_linux.run \
    && sh cuda_12.6.0_560.28.03_linux.run --toolkit --silent --override \
    && rm cuda_12.6.0_560.28.03_linux.run

ENV PATH=/usr/local/cuda-12.6/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH

# 6. Instalar cuDNN 9.0.0
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && dpkg -i cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && cp /var/cudnn-local-repo-ubuntu2204-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcudnn9 libcudnn9-dev \
    && rm cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb

# 7. Atualizar cache de bibliotecas
RUN ldconfig

# 8. Instalar UV
RUN pip install uv

# 9. Clonar repositório DIA
RUN git clone https://github.com/nari-labs/dia.git /opt/dia
WORKDIR /opt/dia

# 10. Criar ambiente virtual e instalar dependências
RUN uv venv --python python3.11

# 11. Comando padrão ao iniciar o container
CMD ["uv", "run", "app.py"]
