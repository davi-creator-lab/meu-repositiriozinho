# Base CUDA runtime
FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

# Evita prompts durante instalação
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Instala dependências do sistema e Python 3.11 via PPA
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common curl wget git && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3.11 python3.11-venv python3.11-distutils && \
    rm -rf /var/lib/apt/lists/*

# Instala o Ultralight CLI (UV) se necessário
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Ajusta PATH do Rust/Cargo caso UV dependa dele
RUN echo 'export PATH="/root/.cargo/bin:$PATH"' >> ~/.bashrc

# Define diretório de trabalho
WORKDIR /app

# Clona repositório da aplicação
RUN git clone https://github.com/nari-labs/dia.git .

# Cria ambiente virtual usando UV
RUN uv venv --python python3.11

# Comando padrão para iniciar a aplicação
CMD ["uv", "run", "python", "-c", "import subprocess; import sys; subprocess.run([sys.executable, 'app.py', '--server-name', '0.0.0.0', '--server-port', '7860'])"]
