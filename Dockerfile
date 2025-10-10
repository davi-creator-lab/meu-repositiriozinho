FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

# Instala dependências do sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.11 python3.11-venv python3.11-distutils \
        curl wget git && \
    rm -rf /var/lib/apt/lists/*

# Instala UV (Astral.sh)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Ajusta PATH para o cargo/UV
ENV PATH="/root/.cargo/bin:$PATH"

# Clona o repositório do seu projeto
WORKDIR /app
RUN git clone https://github.com/nari-labs/dia.git .

# Cria o ambiente virtual com Python 3.11
RUN uv venv --python python3.11

# Expõe a porta que o app vai usar
EXPOSE 7860

# Comando padrão para rodar o app
CMD ["uv", "run", "python", "app.py", "--server-name", "0.0.0.0", "--server-port", "7860"]
