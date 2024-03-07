ARG TAG_FOR_BASE_SAGEMAKER_IMAGE=1.5.2-cpu
FROM --platform=linux/amd64 public.ecr.aws/sagemaker/sagemaker-distribution:$TAG_FOR_BASE_SAGEMAKER_IMAGE

ARG DEBIAN_FRONTEND=noninteractive

# Install docker-cli
COPY docker-cli-install.sh /docker-cli-install.sh
RUN /docker-cli-install.sh

# for OpenCV
RUN sudo apt-get update && \
    sudo apt-get install -y libopencv-dev && \
    sudo rm -rf /var/lib/apt/lists/*

# Update base python
RUN conda install python=3.11.8 --all --yes

# Install poetry and dependences
COPY requirements.txt /requirements.txt
RUN conda run -n base python -m pip install -r /requirements.txt && \
    conda run -n base python -m poetry config virtualenvs.create false
