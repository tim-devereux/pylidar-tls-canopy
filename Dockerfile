# Instructions for running a jupyter server in this conatiner: https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html
FROM jupyter/datascience-notebook:python-3.10

USER root

# Copy files and change ownership
COPY --chown=jovyan:users . /home/jovyan/pylidar-tls-canopy

WORKDIR /home/jovyan/pylidar-tls-canopy

# Download rdblib and rivlib archives
RUN wget -O rdblib.tar.gz https://www.dropbox.com/s/2amep79wytea5if/rdblib-2.4.1-x86_64-linux.tar.gz?dl=0 \
    && wget -O rivlib.zip https://www.dropbox.com/s/rsa6yugmurzf5vk/rivlib-2_6_0-x86_64-linux-gcc9.zip?dl=0 \
    && unzip rivlib.zip -d /usr/local \
    && tar -xf rdblib.tar.gz -C /usr/local \
    && rm -f rdblib.tar.gz rivlib.zip \
    && chown -R jovyan:users /usr/local/rivlib-* /usr/local/rdblib-*

USER jovyan

ENV RIVLIB_ROOT /usr/local/rivlib-2_6_0-x86_64-linux-gcc9
ENV RDBLIB_ROOT /usr/local/rdblib-2.4.1-x86_64-linux

ENV PYLIDAR_CXX_FLAGS -std=c++11
RUN conda install mamba -n base -c conda-forge
RUN mamba env update --file environment.yml
# Build and install the project
RUN pip install . -v
