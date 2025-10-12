# ========================================
# Dockerfile Final - Nari Labs DIA GPU
# Ubuntu 22.04 + CUDA 12.6 + cuDNN 9 + cuSPARSELt + Python 3.11
# ========================================

FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar sistema e instalar dependências básicas
RUN apt-get update && apt-get install -y \
    python3.11 python3.11-venv python3.11-distutils python3-pip \
    curl wget git unzip sudo build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11

# 3. Atualizar pip
RUN python3 -m pip install --upgrade pip

# 4. Instalar cuDNN 9 manualmente (tar + copiar para CUDA)
WORKDIR /tmp
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-12.6-linux-x64-v9.0.0.tgz \
    && tar -xzvf cudnn-12.6-linux-x64-v9.0.0.tgz \
    && cp -P cuda/include/cudnn*.h /usr/local/cuda/include/ \
    && cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64/ \
    && chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn* \
    && rm -rf cudnn-12.6-linux-x64-v9.0.0.tgz cuda

# 5. Instalar cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-12.6-linux-x64-v0.7.1.tgz \
    && tar -xzvf cusparselt-12.6-linux-x64-v0.7.1.tgz \
    && cp -r cusparselt/lib/* /usr/local/cuda/lib64/ \
    && cp -r cusparselt/include/* /usr/local/cuda/include/ \
    && rm -rf cusparselt-12.6-linux-x64-v0.7.1.tgz cusparselt

# 6. Atualizar cache de bibliotecas
RUN ldconfig

# 7. Instalar UV
RUN python3 -m pip install uv

# 8. Clonar e configurar projeto DIA
WORKDIR /root
RUN git clone https://github.com/nari-labs/dia.git
WORKDIR /root/dia

# 9. Criar ambiente virtual Python 3.11 e instalar dependências
RUN python3 -m venv venv
RUN . venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

# 10. Comando padrão para rodar a aplicação
CMD ["/bin/bash", "-c", "source venv/bin/activate && uv run app.py"]
