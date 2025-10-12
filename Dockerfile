# Base CUDA 12.6 (Ubuntu 22.04)
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:$PATH"

# 1. Atualizar pacotes e instalar dependências essenciais
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    software-properties-common \
    ca-certificates \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar Python 3.11 e ferramentas
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3.11-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 3. Definir Python 3.11 como padrão
RUN ln -sf /usr/bin/python3.11 /usr/bin/python && \
    ln -sf /usr/bin/python3.11 /usr/bin/python3

# 4. Instalar cuDNN 9 para CUDA 12.6
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-12.6-linux-x64-v9.0.0.tgz && \
    tar -xzvf cudnn-12.6-linux-x64-v9.0.0.tgz && \
    cp -P cuda/include/cudnn*.h /usr/local/cuda/include/ && \
    cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64/ && \
    chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn* && \
    rm -rf cudnn-12.6-linux-x64-v9.0.0.tgz cuda

# 5. Verificar instalação do Python e CUDA/cuDNN
RUN python --version && \
    nvcc --version || true && \
    ls /usr/local/cuda/lib64/libcudnn*

# 6. Diretório da aplicação
WORKDIR /app

# 7. Copiar código da aplicação
COPY . .

# 8. Atualizar pip
RUN pip install --upgrade pip

# 9. Porta e comando padrão
EXPOSE 7860
CMD ["python", "app.py"]
