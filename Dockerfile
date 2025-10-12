# Use a imagem base Ubuntu 20.04
FROM ubuntu:20.04

# Evita prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza e instala dependências básicas
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    lsb-release \
    gnupg \
    apt-transport-https \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Adiciona o PPA do Deadsnakes para Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa

# Atualiza novamente e instala Python 3.11
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-distutils \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Configura alternativas do python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
    && update-alternatives --set python3 /usr/bin/python3.8

# Instala pip para Python 3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Define diretório de trabalho
WORKDIR /app

# Copia arquivos do projeto (opcional)
# COPY . .

# Comando padrão ao iniciar o container
CMD ["python3", "--version"]
