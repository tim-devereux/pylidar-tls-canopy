# Base image
FROM jupyter/datascience-notebook:python-3.10

# Set user to root for installation and configuration
USER root

# Copy the entire project directory and change ownership
COPY --chown=jovyan:users . /home/jovyan/pylidar-tls-canopy

# Set working directory
WORKDIR /home/jovyan/pylidar-tls-canopy

# Copy and extract rdblib and rivlib archives from a local directory
# Assume the archives are stored in the project directory under `libs/`
# These will have to be copied in after cloning the repo before building the container
COPY --chown=jovyan:users libs/rdblib-2.4.1-x86_64-linux.tar.gz libs/rivlib-2_6_0-x86_64-linux-gcc11.zip /tmp/
RUN tar -xf /tmp/rdblib-2.4.1-x86_64-linux.tar.gz -C /usr/local \
    && unzip /tmp/rivlib-2_6_0-x86_64-linux-gcc11.zip -d /usr/local \
    && rm /tmp/rdblib-2.4.1-x86_64-linux.tar.gz /tmp/rivlib-2_6_0-x86_64-linux-gcc11.zip \
    && chown -R jovyan:users /usr/local/rivlib-* /usr/local/rdblib-*

# Revert to the non-root user 'jovyan'
USER jovyan

# Environment variables for library paths
ENV RIVLIB_ROOT /usr/local/rivlib-2_6_0-x86_64-linux-gcc11
ENV RDBLIB_ROOT /usr/local/rdblib-2.4.1-x86_64-linux

# C++ flags for building any C++ components
ENV PYLIDAR_CXX_FLAGS -std=c++11

# Install mamba for efficient conda operations
RUN conda install mamba -n base -c conda-forge

# Update the environment based on the YML file
RUN mamba env update --file environment.yml

# Build and install the Python package
RUN pip install . -v
