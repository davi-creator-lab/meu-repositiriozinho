# Use a imagem base da NVIDIA com CUDA (runtime)
FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

# Evita interações durante instalações de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza pacotes e instala dependências do sistema + Python padrão do Ubuntu 20.04
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-distutils \
    wget git curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# Atualiza o pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Define o diretório de trabalho
WORKDIR /workspace

# Copie os arquivos do seu projeto (opcional)
# COPY . /workspace

# Comando padrão ao iniciar o container
CMD ["bash"]
