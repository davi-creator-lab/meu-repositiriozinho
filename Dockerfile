# Base com CUDA 12.6
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar pacotes e instalar dependências básicas
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    git \
    unzip \
    sudo \
    build-essential \
    lsb-release \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Adicionar repositório para Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update

# 3. Instalar Python 3.11 e pip
RUN apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 4. Configurar Python 3.11 como padrão
#RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    #&& update-alternatives --set python3 /usr/bin/python3.11

# 5. Atualizar pip
RUN python3 -m pip install --upgrade pip

# 6. Instalar cuDNN 9
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && dpkg -i cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb \
    && cp /var/cudnn-local-repo-ubuntu2204-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcudnn9 libcudnn9-dev \
    && rm cudnn-local-repo-ubuntu2204-9.0.0_1.0-1_amd64.deb

# 7. Instalar cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && dpkg -i cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && cp /var/cusparselt-local-repo-ubuntu2204-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcusparselt0 libcusparselt-dev \
    && rm cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb

# 8. Atualizar cache de bibliotecas
RUN ldconfig

# 9. Instalar UV
RUN python3 -m pip install uv

# 10. Clonar repositório DIA e criar ambiente virtual
RUN git clone https://github.com/nari-labs/dia.git /opt/dia
WORKDIR /opt/dia
RUN python3 -m venv venv
RUN . venv/bin/activate && pip install --upgrade pip

# 11. Expor porta da aplicação
EXPOSE 7860

# 12. Comando para rodar a aplicação
CMD ["/bin/bash", "-c", ". venv/bin/activate && uv run app.py"]
