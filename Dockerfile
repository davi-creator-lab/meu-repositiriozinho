# Use Ubuntu 20.04 como base
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Atualiza pacotes e instala dependências básicas
RUN apt-get update && \
    apt-get install -y software-properties-common curl wget git sudo && \
    rm -rf /var/lib/apt/lists/*

# Adiciona PPA do Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-distutils python3.11-venv && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 && \
    update-alternatives --set python3 /usr/bin/python3.8

# Atualiza pip
RUN python3 -m ensurepip --upgrade && \
    python3 -m pip install --upgrade pip

# Baixa e instala CUDA 12.6
RUN wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda_12.6.0_560.28.03_linux.run && \
    sh cuda_12.6.0_560.28.03_linux.run --toolkit --silent --override && \
    echo 'export PATH=/usr/local/cuda-12.6/bin:$PATH' >> /root/.bashrc && \
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH' >> /root/.bashrc

# Baixa e instala cuDNN 9
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb && \
    dpkg -i cudnn-local-repo-ubuntu2004-9.0.0_1.0-1_amd64.deb && \
    cp /var/cudnn-local-repo-ubuntu2004-9.0.0/cudnn-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get install -y cudnn9-cuda-12 && \
    rm -rf /var/lib/apt/lists/*

# Baixa e instala cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb && \
    dpkg -i cusparselt-local-repo-ubuntu2004-0.7.1_1.0-1_amd64.deb && \
    cp /var/cusparselt-local-repo-ubuntu2004-0.7.1/cusparselt-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get install -y libcusparselt0 libcusparselt-dev && \
    ldconfig && \
    rm -rf /var/lib/apt/lists/*

# Instala uv
RUN python3 -m pip install uv

# Clona o repositório dia e cria o virtualenv
RUN git clone https://github.com/nari-labs/dia.git /opt/dia
WORKDIR /opt/dia
RUN uv venv --python python3.11

# Comando padrão ao rodar o container
CMD ["uv", "run", "app.py"]
