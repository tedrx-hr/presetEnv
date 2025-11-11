# 基础镜像：选择与学校节点驱动兼容的CUDA 12.1和Ubuntu 22.04
FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# 设置环境变量，避免apt-get等工具在构建时出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置默认工作目录
WORKDIR /root

# ----------------- 1. 安装系统依赖 -----------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nano \
    psmisc \
    zip \
    git \
    aria2 \
    axel \
    wget \
    file \
    software-properties-common \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# ----------------- 2. 安装额外的 CUDA Toolkit 11.8 -----------------
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends cuda-toolkit-11-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ----------------- 3. 配置默认CUDA环境 (12.1) -----------------
RUN rm -f /usr/local/cuda && \
    ln -s /usr/local/cuda-12.1 /usr/local/cuda

# 使用ENV指令设置默认的环境变量，指向12.1
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# ----------------- 4. 安装并配置Miniforge (Mamba) -----------------
ENV MINIFORGE_PATH=/root/miniforge
ENV PATH="${MINIFORGE_PATH}/bin:${PATH}"

# 【【【 这是修改的地方 】】】
RUN wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p ${MINIFORGE_PATH} && \
    rm Miniforge3.sh && \
    # 使用 conda init 进行初始化，它在脚本环境中更稳定
    conda init bash

# ----------------- 5. 安装 uv 包管理工具 -----------------
ENV UV_HOME="/root/.local"
ENV PATH="${UV_HOME}/bin:${PATH}"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN ln -s /root/.local/bin/uv /usr/local/bin/uv
RUN ln -s /root/.local/bin/uvx /usr/local/bin/uvx

# ----------------- 6. 配置软件源和Git -----------------
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple && \
    git config --global user.name 'linkslinks' && \
    git config --global user.email 'fyj2003116@qq.com'

# ----------------- 7. 克隆项目代码 -----------------
RUN git clone https://gitee.com/gitee_fu/easy-tools.git

# ----------------- 8. 创建CUDA版本切换工具 -----------------
RUN <<'EOF' tee -a /root/.bashrc > /dev/null

# Function to switch between installed CUDA versions
use_cuda() {
    if [ -z "$1" ]; then
        echo "Usage: use_cuda <version>"
        echo "Available versions:"
        ls -d /usr/local/cuda-* | sed 's/.*cuda-//' | sort -V
        return 1
    fi

    local CUDAPATH="/usr/local/cuda-$1"
    if [ ! -d "${CUDAPATH}" ]; then
        echo "Error: CUDA version $1 not found at ${CUDAPATH}"
        return 1
    fi

    echo "Switching to CUDA $1..."

    # Update the symlink
    rm -f /usr/local/cuda
    ln -s "${CUDAPATH}" /usr/local/cuda

    # Update environment variables for the current shell session
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v '/usr/local/cuda' | paste -sd:)
    export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | tr ':' '\n' | grep -v '/usr/local/cuda' | paste -sd:)
    export PATH="${CUDAPATH}/bin:${PATH}"
    export LD_LIBRARY_PATH="${CUDAPATH}/lib64:${LD_LIBRARY_PATH}"

    echo "Successfully switched to CUDA $1."
    echo -n "nvcc version: "
    nvcc -V
}
EOF

# ----------------- 9. 设置容器启动时的默认命令 -----------------
# 默认进入bash，以便用户可以交互式操作
CMD ["bash"]
