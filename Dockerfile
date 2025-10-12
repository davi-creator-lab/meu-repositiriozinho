# =====================================
# NARI LABS DIA - Dockerfile Ubuntu 22.04
# Python 3.11, CUDA 12.6, cuDNN 9
# =====================================

# Base com CUDA 12.6 Runtime
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# 1. Atualizar sistema e instalar dependências
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl wget git unzip sudo build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar Python 3.11 e pip
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.11 python3.11-venv python3.11-distutils python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 3. Configurar Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11 \
    && python3 --version

# 4. Atualizar pip
RUN python3 -m pip install --upgrade pip

# 5. Instalar CUDA Toolkit (opcional, caso precise compilar código CUDA)
RUN wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda_12.6.0_560.28.03_linux.run \
    && sh cuda_12.6.0_560.28.03_linux.run --toolkit --silent --override \
    && rm cuda_12.6.0_560.28.03_linux.run

# 6. Configurar variáveis de ambiente CUDA
ENV PATH=/usr/local/cuda-12.6/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH

# 7. Instalar cuDNN 9 via tarball
RUN wget https://developer.download.nvidia.com/compute/cudnn/9.0.0/local_installers/cudnn-9.0-linux-x64-v9.0.176.5.tgz \
    && tar -xzf cudnn-9.0-linux-x64-v9.0.176.5.tgz -C /usr/local \
    && rm cudnn-9.0-linux-x64-v9.0.176.5.tgz \
    && ldconfig

# 8. Instalar cuSPARSELt
RUN wget https://developer.download.nvidia.com/compute/cusparselt/0.7.1/local_installers/cusparselt-linux-x86_64-0.7.1.tgz \
    && tar -xzf cusparselt-linux-x86_64-0.7.1.tgz -C /usr/local \
    && rm cusparselt-linux-x86_64-0.7.1.tgz \
    && ldconfig

# 9. Instalar UV (Virtual environment manager / runner)
RUN python3 -m pip install uv

# 10. Clonar projeto DIA e configurar venv
WORKDIR /root/
RUN git clone https://github.com/nari-labs/dia.git
WORKDIR /root/dia
RUN uv venv --python python3.11

# 11. Expor porta padrão da aplicação
EXPOSE 7860

# 12. Comando default para rodar o app
CMD ["uv", "run", "app.py"]
