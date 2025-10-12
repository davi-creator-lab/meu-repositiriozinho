# =========================================
# Dockerfile Nari Labs DIA
# Ubuntu 20.04 + CUDA 12.6 + cuDNN 9.0 + Python 3.10
# =========================================

FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar sistema e instalar ferramentas básicas e Python 3.10
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-dev \
    wget \
    git \
    build-essential \
    ca-certificates \
    lsb-release \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 2. Garantir que 'python3' aponte para Python 3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# 3. Atualizar pip
RUN python3 -m pip install --upgrade pip

# 4. Instalar cuDNN 9.0 (Ubuntu 20.04)
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb \
    && dpkg -i cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb \
    && cp /var/cudnn-local-repo-ubuntu2004-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcudnn9 libcudnn9-dev \
    && rm cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb

# 5. Atualizar cache de bibliotecas
RUN ldconfig

# 6. Instalar UV
RUN pip install uv

# 7. Clonar o projeto
RUN git clone https://github.com/nari-labs/dia.git /dia
WORKDIR /dia

# 8. Criar ambiente virtual e instalar dependências
RUN uv venv --python python3.10

# 9. Expor a porta padrão da aplicação
EXPOSE 7860

# 10. Comando de inicialização
CMD ["uv", "run", "app.py"]
