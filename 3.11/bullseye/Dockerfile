FROM --platform=linux/amd64 public.ecr.aws/docker/library/python:3.11.8-bullseye

ARG NB_USER="sagemaker-user"
ARG NB_UID=1000
ARG NB_GID=100

# Setup the "sagemaker-user" user with root privileges.
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd --create-home --shell /bin/bash --gid "${NB_GID}" --uid ${NB_UID} ${NB_USER} && \
    echo "${NB_USER}    ALL=(ALL)    NOPASSWD:    ALL" >> /etc/sudoers && \
    rm -rf /var/lib/apt/lists/*

# Install JupyterLab & AWS CLI
RUN python3 -m pip install jupyterlab==4.1.0 \
                           sagemaker==2.207.1 \
                           https://github.com/aws/aws-cli/archive/v2.tar.gz

# Docker - https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html

# Add Docker's official GPG key:
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker (Studio only supports Docker version 20.10.X.)
RUN apt-get update && \
    apt-get install -y docker-ce=5:20.10.* docker-ce-cli=5:20.10.* containerd.io docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

ENV SHELL=/bin/bash

ENTRYPOINT ["jupyter-lab"]
CMD ["--ServerApp.ip=0.0.0.0", "--ServerApp.port=8888", "--ServerApp.allow_origin=*", "--ServerApp.token=''", "--ServerApp.base_url=/jupyterlab/default"]
