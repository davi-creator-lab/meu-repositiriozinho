# ==============================================
# Dockerfile para Nari Labs DIA - Ubuntu 22.04
# GPU NVIDIA, Python 3.11, CUDA 12.6, cuDNN 9, cuSPARSELt
# ==============================================

# Base com CUDA runtime 12.6 e Ubuntu 22.04
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

# Evitar interação do apt
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar sistema e instalar dependências básicas
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl wget git unzip sudo build-essential \
    python3.11 python3.11-venv python3.11-distutils python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2

# 3. Atualizar pip
RUN python3 -m ensurepip --upgrade \
    && python3 -m pip install --upgrade pip

# 4. Instalar UV
RUN pip install uv

# 5. Instalar cuDNN 9
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && dpkg -i cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && cp /var/cudnn-local-repo-ubuntu2204-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcudnn9 libcudnn9-dev \
    && rm -rf /var/lib/apt/lists/*

# 6. Instalar cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && dpkg -i cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && cp /var/cusparselt-local-repo-ubuntu2204-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcusparselt0 libcusparselt-dev \
    && rm -rf /var/lib/apt/lists/*

# 7. Atualizar cache de bibliotecas
RUN ldconfig

# 8. Clonar e configurar projeto DIA
RUN git clone https://github.com/nari-labs/dia.git /opt/dia
WORKDIR /opt/dia

# 9. Criar ambiente virtual com UV
RUN uv venv --python python3.11

# 10. Expõe porta da aplicação
EXPOSE 7860

# 11. Comando padrão para iniciar a aplicação
CMD ["uv", "run", "app.py"]
