ARG TAG_FOR_BASE_SAGEMAKER_IMAGE=1.5.2-cpu
FROM --platform=linux/amd64 public.ecr.aws/sagemaker/sagemaker-distribution:$TAG_FOR_BASE_SAGEMAKER_IMAGE

ARG DEBIAN_FRONTEND=noninteractive

# Install docker-cli
COPY docker-cli-install.sh ./
RUN ./docker-cli-install.sh

# for OpenCV
RUN sudo apt-get update && \
    sudo apt-get install -y libopencv-dev && \
    sudo rm -rf /var/lib/apt/lists/*

# Install poetry to base python
RUN conda run -n base python -m pip install poetry==1.8.2 

# Add kernel - Python 3.11
RUN conda create --yes -n py311 python=3.11.8 ipykernel pytorch torchvision -c pytorch && \
    conda run -n py311 python -m pip install poetry==1.8.2 && \
    conda run -n py311 python -m ipykernel install --prefix /opt/conda --name "python3.11" --display-name "Python 3.11 (Anaconda)"

# Add kernel - Python 3.12
RUN conda create --yes -n py312 python=3.12.2 ipykernel pytorch torchvision -c pytorch && \
    conda run -n py311 python -m pip install poetry==1.8.2 && \
    conda run -n py312 python -m ipykernel install --prefix /opt/conda --name "python3.12" --display-name "Python 3.12 (Anaconda)"
