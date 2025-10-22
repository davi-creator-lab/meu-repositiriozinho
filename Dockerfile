FROM nvidia/cuda:12.6.0-devel-ubuntu22.04

# Evita prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza e instala dependências básicas
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Atualiza pip
RUN python3 -m pip install --upgrade pip

# Clona o repositório
RUN git clone https://github.com/nari-labs/dia.git /app/dia

# Define o diretório de trabalho
WORKDIR /app

# Baixa e instala cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && dpkg -i cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && cp /var/cusparselt-local-repo-ubuntu2204-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcusparselt0 libcusparselt-dev \
    && ldconfig \
    && rm cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Baixa e instala CUDA keyring e cuDNN
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y libcudnn9-cuda-12 libcudnn9-dev-cuda-12 \
    && ldconfig \
    && rm cuda-keyring_1.1-1_all.deb \
    && rm -rf /var/lib/apt/lists/*

# Instala uv
RUN pip install uv

# Muda para o diretório do projeto
WORKDIR /app/dia

# Atualiza ldconfig
RUN ldconfig

# Cria o ambiente virtual com Python 3.10
RUN uv venv --python python3.10

# Comando padrão para executar a aplicação
CMD ["uv", "run", "app.py"]
