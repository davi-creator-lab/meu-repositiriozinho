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
    && apt-get install -y libcusparselt0 libcusparselt-dev \
    && rm cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Baixa e instala CUDA keyring e cuDNN
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y libcudnn9-cuda-12 libcudnn9-dev-cuda-12 \
    && rm cuda-keyring_1.1-1_all.deb \
    && rm -rf /var/lib/apt/lists/*

# Limpa cache para liberar espaço antes do próximo passo
RUN apt-get clean && rm -rf /var/cache/apt/* /tmp/* /var/tmp/*

# Instala uv e hf_xet para download otimizado
RUN pip install --no-cache-dir uv huggingface_hub[hf_xet]

WORKDIR /app/dia

# Cria o ambiente virtual e instala dependências
RUN uv venv --python python3.10 \
    && . .venv/bin/activate \
    && uv pip install -r requirements.txt 2>/dev/null || echo "No requirements.txt found" \
    && uv pip install hf_xet

# Configura cache do Hugging Face para o diretório do projeto
ENV HF_HOME=/app/dia/.cache/huggingface
ENV HF_HUB_CACHE=/app/dia/.cache/huggingface/hub

# Cria o diretório de cache
RUN mkdir -p $HF_HOME

# Executa app.py pela primeira vez para fazer download dos modelos
# O timeout evita que fique rodando indefinidamente
RUN timeout 300 uv run app.py || echo "Setup inicial completo (modelos baixados)"

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

# Copia o código da aplicação, ambiente virtual E os modelos baixados
COPY --from=builder /app/dia /app/dia

WORKDIR /app/dia

# Instala uv no runtime
RUN pip install --no-cache-dir uv

# Variáveis de ambiente
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV HF_HOME=/app/dia/.cache/huggingface
ENV HF_HUB_CACHE=/app/dia/.cache/huggingface/hub

# Comando padrão para executar a aplicação
CMD ["uv", "run", "app.py"]
