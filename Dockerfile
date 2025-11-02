FROM docker.1ms.run/nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# RUN apt-get update && apt-get install -y libgl1-mesa-glx libpci-dev curl nano psmisc zip git && apt-get --fix-broken install -y

# RUN conda install -y scikit-learn pandas flake8 yapf isort yacs future libgcc

# RUN pip install --upgrade pip && python -m pip install --upgrade setuptools && \
#     pip install opencv-python tb-nightly matplotlib logger_tt tabulate tqdm wheel mccabe scipy

RUN apt-get update && apt-get install -y curl nano psmisc zip git && apt-get --fix-broken install -y && cd ~

RUN git clone https://gitee.com/gitee_fu/easy-tools.git

RUN bash easy-tools/setup_and_run.sh

COPY ./fonts/* /opt/conda/lib/python3.10/site-packages/matplotlib/mpl-data/fonts/ttf/
