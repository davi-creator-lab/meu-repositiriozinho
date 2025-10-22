# ===============================
# 🔹 BASE CUDA 12.6 + Ubuntu 20.04
# ===============================
FROM nvidia/cuda:12.6.0-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# ===============================
# 🔹 DEPENDÊNCIAS BÁSICAS
# ===============================
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

# ===============================
# 🔹 COMPILAÇÃO DO PYTHON 3.11
# ===============================
RUN cd /tmp \
    && wget https://www.python.org/ftp/python/3.11.8/Python-3.11.8.tgz \
    && tar -xf Python-3.11.8.tgz \
    && cd Python-3.11.8 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall \
    && cd / && rm -rf /tmp/Python-3.11.8 /tmp/Python-3.11.8.tgz

# Define o Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.11 1

# Atualiza pip e ferramentas
RUN python3 -m ensurepip --upgrade \
    && python3 -m pip install --upgrade pip setuptools wheel

# ===============================
# 🔹 INSTALA CUDA DNN + cuSPARSELt
# ===============================
RUN rm -f /etc/apt/sources.list.d/cuda*.list \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y libcudnn9-cuda-12 libcudnn9-dev-cuda-12 \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb \
    && dpkg -i cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb \
    && cp /var/cusparselt-local-repo-ubuntu2004-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y libcusparselt0 libcusparselt-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ldconfig

# ===============================
# 🔹 INSTALA FERRAMENTAS ÚTEIS
# ===============================
RUN pip install uv

# ===============================
# 🔹 CLONA O SEU PROJETO
# ===============================
RUN git clone https://github.com/nari-labs/dia.git /root/dia
WORKDIR /root/dia

# Cria e prepara o ambiente virtual
RUN python3 -m venv venv \
    && . venv/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# ===============================
# 🔹 “ENGANA” o NodeShift com uma porta ativa
# ===============================
EXPOSE 7860

# Mantém o container ativo e simula um serviço
CMD ["bash", "-c", "python3 -m http.server 7860 & tail -f /dev/null"]
