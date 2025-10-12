# =====================================
# Dockerfile Nari Labs DIA - Ubuntu 22.04
# CUDA 12.6 + cuDNN + Python 3.11
# =====================================

FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

# Evitar interação durante instalações
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar sistema e instalar ferramentas básicas
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    git \
    unzip \
    sudo \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar Python 3.11 e pip
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
       python3.11 \
       python3.11-venv \
       python3.11-distutils \
       python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 3. Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11

# 4. Atualizar pip
RUN python3 -m pip install --upgrade pip

# 5. Instalar cuDNN (última compatível com CUDA 12.6)
RUN wget https://developer.download.nvidia.com/compute/redist/cudnn/v9.2.0/cudnn-12.6-linux-x64-v9.2.0.tgz \
    && tar -xzf cudnn-12.6-linux-x64-v9.2.0.tgz \
    && cp -P cuda/include/cudnn*.h /usr/local/cuda/include/ \
    && cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64/ \
    && chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn* \
    && rm -rf cudnn-12.6-linux-x64-v9.2.0.tgz cuda

# 6. Criar links simbólicos para “enganar” apps que procuram cuDNN 9
RUN ln -s /usr/local/cuda/lib64/libcudnn.so /usr/local/cuda/lib64/libcudnn.so.9 \
    && ln -s /usr/local/cuda/lib64/libcudnn.so /usr/local/cuda/lib64/libcudnn.so.9.0.0

# 7. Configurar variáveis de ambiente CUDA
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# 8. Instalar UV (gerenciador de ambiente/app do DIA)
RUN pip install uv

# 9. Clonar o repositório do DIA
RUN git clone https://github.com/nari-labs/dia.git /dia
WORKDIR /dia

# 10. Criar ambiente virtual com Python 3.11
RUN uv venv --python python3.11

# 11. Expôr a porta padrão do app
EXPOSE 7860

# 12. Comando padrão para rodar a aplicação
CMD ["uv", "run", "app.py"]
