# ============================================
# Stage 1: Builder - Instala dependências e configura ambiente
# ============================================
FROM nvidia/cuda:12.6.0-devel-ubuntu22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências de build
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    git \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Atualiza pip
RUN python3 -m pip install --upgrade pip

# Clona o repositório
RUN git clone https://github.com/nari-labs/dia.git /app/dia

WORKDIR /app

# Baixa e instala cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && dpkg -i cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && cp /var/cusparselt-local-repo-ubuntu2204-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcusparselt0 libcusparselt-dev

# Baixa e instala CUDA keyring e cuDNN
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y libcudnn9-cuda-12 libcudnn9-dev-cuda-12

# Instala uv e cria ambiente virtual
RUN pip install uv

WORKDIR /app/dia

# Cria o ambiente virtual e instala dependências
RUN uv venv --python python3.10 \
    && . .venv/bin/activate \
    && uv pip install -r requirements.txt 2>/dev/null || echo "No requirements.txt found"

# Executa app.py pela primeira vez para fazer a instalação inicial
RUN uv run app.py || echo "Primeira execução completa (setup inicial)"

# ============================================
# Stage 2: Runtime - Imagem final otimizada
# ============================================
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instala apenas dependências runtime necessárias
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia cuSPARSELt (necessário para runtime)
COPY --from=builder /usr/lib/x86_64-linux-gnu/libcusparselt* /usr/lib/x86_64-linux-gnu/

# Reinstala cuDNN runtime (não precisa do -dev)
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y libcudnn9-cuda-12 \
    && rm cuda-keyring_1.1-1_all.deb \
    && rm -rf /var/lib/apt/lists/*

# Atualiza ldconfig
RUN ldconfig

# Copia o código da aplicação e ambiente virtual do builder
COPY --from=builder /app/dia /app/dia

WORKDIR /app/dia

# Instala uv no runtime
RUN pip install --no-cache-dir uv

# Variáveis de ambiente para otimização
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Comando padrão para executar a aplicação
CMD ["uv", "run", "app.py"]
