# =============================================
# NARI LABS DIA - Dockerfile atualizado
# Ubuntu 22.04 + CUDA 12.6 + cuDNN 9.6
# =============================================

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
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.11 python3.11-venv python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

# 3. Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
    && update-alternatives --set python3 /usr/bin/python3.11

# 4. Instalar pip
RUN python3 -m ensurepip \
    && python3 -m pip install --upgrade pip

# 5. Instalar CUDA 12.6 Toolkit
RUN wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda_12.6.0_560.28.03_linux.run \
    && sh cuda_12.6.0_560.28.03_linux.run --toolkit --silent --override \
    && rm cuda_12.6.0_560.28.03_linux.run

# Configurar variáveis de ambiente CUDA
ENV PATH=/usr/local/cuda-12.6/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH

# 6. Instalar cuDNN 9.6 para CUDA 12.6
RUN wget https://developer.download.nvidia.com/compute/redist/cudnn/v9.6.0/cudnn-12.6-linux-x64-v9.6.0.tgz \
    && tar -xzf cudnn-12.6-linux-x64-v9.6.0.tgz \
    && cp -P cuda/include/cudnn*.h /usr/local/cuda/include/ \
    && cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64/ \
    && chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn* \
    && rm -rf cudnn-12.6-linux-x64-v9.6.0.tgz cuda

# Atualizar cache de bibliotecas
RUN ldconfig

# 7. Instalar UV
RUN python3 -m pip install uv

# 8. Clonar projeto DIA
RUN git clone https://github.com/nari-labs/dia.git /opt/dia
WORKDIR /opt/dia

# 9. Criar ambiente virtual e instalar dependências
RUN uv venv --python python3.11

# 10. Expor porta
EXPOSE 7860

# 11. Comando padrão para iniciar o app
CMD ["uv", "run", "app.py"]
