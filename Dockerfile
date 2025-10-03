FROM nvidia/cuda:12.6-runtime-ubuntu20.04

RUN apt update && apt install -y python3.11 python3.11-venv curl wget git
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN echo 'export PATH="/root/.cargo/bin:$PATH"' >> ~/.bashrc

WORKDIR /app
RUN git clone https://github.com/nari-labs/dia.git .
RUN uv venv --python python3.11

CMD ["uv", "run", "python", "-c", "import subprocess; import sys; subprocess.run([sys.executable, 'app.py', '--server-name', '0.0.0.0', '--server-port', '7860'])"]
