FROM nvidia/cuda:12.6.0-devel-ubuntu22.04

# Evita prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza repositórios e instala Python
RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    python3-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Atualiza pip
RUN python3 -m pip install --upgrade pip

# Instala cuSPARSELt
WORKDIR /tmp
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb && \
    dpkg -i cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb && \
    cp /var/cusparselt-local-repo-ubuntu2204-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get install -y libcusparselt0 libcusparselt-dev && \
    rm -f cusparselt-local-repo-ubuntu2204-0.7.1_1.0-1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# Atualiza ldconfig após instalar cuSPARSELt
RUN ldconfig

# Instala CUDA keyring e cuDNN
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install -y libcudnn9-cuda-12 libcudnn9-dev-cuda-12 && \
    rm -f cuda-keyring_1.1-1_all.deb && \
    rm -rf /var/lib/apt/lists/*

# Atualiza ldconfig após instalar cuDNN
RUN ldconfig

# Instala uv (gerenciador de pacotes Python rápido)
RUN pip install uv

# Define o diretório de trabalho
WORKDIR /workspace

# Comando padrão
CMD ["/bin/bash"]
