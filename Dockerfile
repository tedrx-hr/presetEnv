FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# RUN echo 'Acquire::http::Proxy "http://172.17.171.249:8888";' > /etc/apt/apt.conf.d/proxy.conf && \
#     echo 'Acquire::https::Proxy "http://172.17.171.249:8888";' >> /etc/apt/apt.conf.d/proxy.conf

# RUN apt-get update && apt-get install -y libgl1-mesa-glx libpci-dev curl nano psmisc zip git && apt-get --fix-broken install -y

# RUN conda install -y scikit-learn pandas flake8 yapf isort yacs future libgcc

# RUN pip install --upgrade pip && python -m pip install --upgrade setuptools && \
#     pip install opencv-python tb-nightly matplotlib logger_tt tabulate tqdm wheel mccabe scipy

WORKDIR /root

RUN apt-get update && apt-get install -y curl nano psmisc zip git aria2 axel && apt-get --fix-broken install -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN cd /root

RUN git clone https://gitee.com/gitee_fu/easy-tools.git

# RUN bash easy-tools/setup_and_run.sh

# COPY ./fonts/* /opt/conda/lib/python3.10/site-packages/matplotlib/mpl-data/fonts/ttf/

# --- 在这里设置全局环境变量 ---
ENV http_proxy="http://172.17.171.249:8888"
ENV https_proxy="http://172.17.171.249:8888"
ENV no_proxy="localhost,127.0.0.1,harbor.fzu.edu.cn,.fzu.edu.cn,172.16.0.0/12,10.0.0.0/8,192.168.0.0/16"
# -----------------------------
