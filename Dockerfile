# 1) Base Fedora
FROM fedora:39

# 2) Atualizar pacotes e instalar plugin 'dnf-plugins-core' (necessário para config-manager)
RUN dnf -y update && dnf clean all
RUN dnf -y install dnf-plugins-core

# 3) Instalar Python, Dev tools, etc.
RUN dnf -y install \
    python3.11 python3.11-devel \
    git \
    cmake make gcc-c++ \
    pciutils nvtop \
    # Caso queira instalar o toolkit do CUDA (usuário-espaço):
    && dnf config-manager --add-repo \
        https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo \
    && dnf clean all \
    && dnf -y install cuda-toolkit-12-4 \
    && dnf clean all

# Configurar variáveis de ambiente para CUDA
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64
ENV PATH=$PATH:$CUDA_HOME/bin

# Criar e ativar venv em /opt/venv
RUN python3.11 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 4) Instalar PyTorch com suporte a CUDA a partir do index oficial PyTorch
#    Veja https://pytorch.org/get-started/locally/
#    Exemplo: CUDA 12.1 => --index-url https://download.pytorch.org/whl/cu121
#              CUDA 12.2 => cu122, etc.
#    Se quiser 2.1, 2.0, etc., ajuste conforme a doc.
RUN pip install --upgrade pip setuptools wheel
RUN pip install pip-tools
RUN pip install torch --index-url https://download.pytorch.org/whl/cu124

# 5) Baixar o repositório do InstructLab e instalar com extra [cuda]
RUN git clone https://github.com/instructlab/instructlab.git /opt/instructlab
WORKDIR /opt/instructlab

RUN pip install .[cuda]

ENV TORCH_CUDA_ARCH_LIST="5.0 6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6 8.9 9.0"

# 6) (Opcional) Reinstalar llama-cpp-python compilando com CUDA
RUN pip cache remove llama_cpp_python || true
RUN pip install --force-reinstall --no-deps llama_cpp_python==0.3.2 \
      -C cmake.args="-DGGML_CUDA=on"

# 7) (Opcional) Reinstalar o InstructLab final, caso queira garantir atualização de dependências
#RUN pip install .[cuda]

# CMD default: mostrar o help
CMD ["bash"]
