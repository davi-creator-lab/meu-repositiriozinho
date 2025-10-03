# Imagem base com CUDA 12.6 + cuDNN 9
FROM nvidia/cuda:12.6.0-cudnn9-runtime-ubuntu20.04

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    python3.11 python3.11-distutils python3.11-venv wget git curl \
    && rm -rf /var/lib/apt/lists/*

# Definir Python 3.11 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2

# Atualizar pip
RUN python3 -m ensurepip --upgrade && python3 -m pip install --upgrade pip

# Instalar uv
RUN pip install uv

# Clonar o repositório DIA
RUN git clone https://github.com/nari-labs/dia.git /app/dia
WORKDIR /app/dia

# Criar o ambiente virtual com uv
RUN uv venv --python python3.11

# Instalar dependências do projeto (se tiver requirements)
# RUN uv pip install -r requirements.txt

# Expor a porta do servidor
EXPOSE 7860

# Comando padrão ao rodar o container
CMD ["uv", "run", "python", "app.py", "--server-name", "0.0.0.0", "--server-port", "7860"]
