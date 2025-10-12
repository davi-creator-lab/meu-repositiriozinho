# Base CUDA 12.6 com cuDNN runtime
FROM nvidia/cuda:12.6.0-cudnn-runtime-ubuntu22.04

# Evita prompts durante instalação
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Instala dependências do sistema e Python 3.11
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common curl wget git build-essential && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3.11 python3.11-venv python3.11-distutils && \
    rm -rf /var/lib/apt/lists/*

# Instala Ultralight CLI (UV)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Ajusta PATH do Rust/Cargo caso UV dependa dele
RUN echo 'export PATH="/root/.cargo/bin:$PATH"' >> ~/.bashrc

# Define diretório de trabalho
WORKDIR /app

# Clona repositório da aplicação
RUN git clone https://github.com/nari-labs/dia.git .

# Cria ambiente virtual usando UV com Python 3.11
RUN uv venv --python python3.11

# Instala PyTorch compatível com CUDA 12.6 dentro do ambiente UV
RUN /bin/bash -c "source .venv/bin/activate && pip install --upgrade pip && \
    pip install torch --index-url https://download.pytorch.org/whl/cu126"

# Define o comando padrão para iniciar a aplicação
CMD ["uv", "run", "app.py", "--server-name", "0.0.0.0", "--server-port", "7860"]
