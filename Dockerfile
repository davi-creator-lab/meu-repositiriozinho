# Base com CUDA 12.6
FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Atualização e dependências básicas
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    software-properties-common \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    liblzma-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Baixar e compilar Python 3.11
RUN cd /tmp \
    && wget https://www.python.org/ftp/python/3.11.8/Python-3.11.8.tgz \
    && tar -xf Python-3.11.8.tgz \
    && cd Python-3.11.8 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall \
    && cd / && rm -rf /tmp/Python-3.11.8 /tmp/Python-3.11.8.tgz

# Configurar python3 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.11 1

# Atualizar pip e instalar venv/distutils
RUN python3 -m ensurepip --upgrade \
    && python3 -m pip install --upgrade pip setuptools wheel

# Instalar cuDNN 9 para CUDA 12.6 (nome correto para repositório atual)
RUN rm -f /etc/apt/sources.list.d/cuda*.list \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y libcudnn9-cuda-12 libcudnn9-dev-cuda-12 \
    && rm -rf /var/lib/apt/lists/*

# Instalar cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb \
    && dpkg -i cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb \
    && cp /var/cusparselt-local-repo-ubuntu2004-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcusparselt0 libcusparselt-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ldconfig

# Instalar uv (se for o mesmo que você usava)
RUN pip install uv

# Clonar o repositório e criar venv
RUN git clone https://github.com/nari-labs/dia.git /root/dia
WORKDIR /root/dia
RUN python3 -m venv venv \
    && . venv/bin/activate \
    && pip install --upgrade pip setuptools wheel

# Comando padrão ao iniciar o container
CMD ["/bin/bash"]
