# =========================================
# Dockerfile Nari Labs DIA
# Ubuntu 20.04 + CUDA 12.6 + cuDNN 9.0 + Python 3.11
# =========================================

FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar sistema e instalar ferramentas básicas
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    sudo \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.11 python3.11-venv python3.11-distutils python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
    && update-alternatives --set python3 /usr/bin/python3.11

# 4. Instalar pip
RUN python3 -m ensurepip --upgrade \
    && python3 -m pip install --upgrade pip

# 5. Instalar cuDNN 9.0
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb \
    && dpkg -i cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb \
    && cp /var/cudnn-local-repo-ubuntu2004-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcudnn9 libcudnn9-dev \
    && rm cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb

# 6. Atualizar cache de bibliotecas
RUN ldconfig

# 7. Instalar UV
RUN pip install uv

# 8. Clonar e configurar projeto DIA
RUN git clone https://github.com/nari-labs/dia.git /dia

WORKDIR /dia

# 9. Criar ambiente virtual com Python 3.11 e instalar dependências
RUN uv venv --python python3.11

# 10. Expor porta
EXPOSE 7860

# 11. Comando para iniciar a aplicação
CMD ["uv", "run", "app.py"]
