# Base com CUDA 12.6
FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

# Evitar interações durante a instalação
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Atualizar pacotes e instalar dependências
RUN apt-get update && apt-get install -y \
    python3.8 python3.11 python3.11-venv python3.11-distutils \
    python3-pip curl wget git unzip sudo build-essential \
    && rm -rf /var/lib/apt/lists/*

# Configurar alternativas para o Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
    && update-alternatives --set python3 /usr/bin/python3.11

# Atualizar pip para o Python 3.11
RUN python3 -m ensurepip \
    && python3 -m pip install --upgrade pip setuptools wheel

# Diretório de trabalho
WORKDIR /app

# Copiar requisitos (caso tenha)
# COPY requirements.txt .
# RUN pip install -r requirements.txt

# Copiar aplicação
# COPY . .

# Comando padrão (pode ser alterado)
CMD ["python3"]
