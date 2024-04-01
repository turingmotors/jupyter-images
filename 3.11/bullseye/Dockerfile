# Define global args
ARG FFMPEG_DIR=/opt/ffmpeg

# Stage 1 - build ffmpeg
FROM --platform=linux/amd64 public.ecr.aws/docker/library/buildpack-deps:bullseye as ffmpeg_builder

RUN apt-get update && apt-get install -y \
      cmake \
      yasm \
      libx264-dev \
      libx265-dev \
    && rm -rf /var/lib/apt/lists/*

ARG FFMPEG_DIR

WORKDIR /usr/local/src

ARG FFMPEG_VERSION=6.1
ARG PKG_CONFIG_PATH="${FFMPEG_DIR}/lib/pkgconfig"

RUN git clone --depth=1 -b release/${FFMPEG_VERSION} https://github.com/FFmpeg/FFmpeg . \
    && ./configure \
      --prefix="${FFMPEG_DIR}" \
      --bindir="${FFMPEG_DIR}/bin" \
      --enable-libx264 --enable-gpl --enable-nonfree \
      --enable-libx265 \
      --enable-shared \
    && make -j $(nproc) \
    && make install

# Stage 2 - build final container
FROM --platform=linux/amd64 public.ecr.aws/docker/library/python:3.11.8-bullseye

ARG DEBIAN_FRONTEND=noninteractive

# Copy ffmpeg
ARG FFMPEG_DIR
COPY --from=ffmpeg_builder ${FFMPEG_DIR} ${FFMPEG_DIR}
ENV LD_LIBRARY_PATH="${FFMPEG_DIR}/lib" \
    FFMPEG_BINARY=${FFMPEG_DIR}/bin/ffmpeg

RUN ln -s ${FFMPEG_DIR}/bin/ffmpeg /usr/local/bin/ffmpeg
RUN ln -s ${FFMPEG_DIR}/bin/ffprobe /usr/local/bin/ffprobe

ARG NB_USER="sagemaker-user" \
    NB_UID=1000 \
    NB_GID=100

# Setup the "sagemaker-user" user with root privileges.
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd --create-home --shell /bin/bash --gid "${NB_GID}" --uid ${NB_UID} ${NB_USER} && \
    echo "${NB_USER}    ALL=(ALL)    NOPASSWD:    ALL" >> /etc/sudoers && \
    rm -rf /var/lib/apt/lists/*

# Install docker-cli and github-cli
COPY docker-cli-install.sh github-cli-install.sh /tmp/
RUN /tmp/docker-cli-install.sh \
    && /tmp/github-cli-install.sh

RUN apt-get update && apt-get install -y \
      cron \
      libgl1-mesa-dev \
      libx264-dev \
      libx265-dev \
    && rm -rf /var/lib/apt/lists/*

# Install poetry and dependences
COPY requirements.txt ./
RUN pip install -r requirements.txt

ENV IDLE_TIME_IN_SECONDS=3600 \
    IGNORE_CONNECTIONS=True \
    SKIP_TERMINALS=False \
    SOLUTION_DIR=/var/tmp/auto-stop-idle

ENV JL_HOSTNAME=0.0.0.0 \
    JL_PORT=8888 \
    JL_BASE_URL=/jupyterlab/default/ \
    LOG_FILE=/var/log/apps/app_container.log \
    STATE_FILE=$SOLUTION_DIR/auto_stop_idle.st

RUN mkdir -p $SOLUTION_DIR \
    && echo "*/2 * * * * /bin/bash -ic 'python -m sagemaker_studio_jlab_auto_stop_idle.auto_stop_idle \
    --idle-time $IDLE_TIME_IN_SECONDS \
    --hostname $JL_HOSTNAME \
    --port $JL_PORT \
    --base-url $JL_BASE_URL \
    --ignore-connections $IGNORE_CONNECTIONS \
    --skip-terminals $SKIP_TERMINALS \
    --state-file-path $STATE_FILE >> $LOG_FILE'" | crontab -

WORKDIR /home/$NB_USER

USER $NB_USER

ENV PATH=/home/$NB_USER/.local/bin:$PATH \
    SHELL=/bin/bash

ENTRYPOINT ["jupyter-lab"]
CMD ["--ServerApp.ip=0.0.0.0", "--ServerApp.port=8888", "--ServerApp.allow_origin=*", "--ServerApp.token=''", "--ServerApp.base_url=/jupyterlab/default"]
