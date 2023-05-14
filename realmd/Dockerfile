# Download base image ubuntu
FROM ubuntu:20.04 AS builder

# Fetch build arguments
ARG CORE_COMMIT_HASH=HEAD \
    DB_COMMIT_HASH=HEAD

# Set Timezone
ENV TZ=Europe/Amsterdam \
    ENV_CORE_COMMIT_HASH=$CORE_COMMIT_HASH \
    ENV_DB_COMMIT_HASH=$DB_COMMIT_HASH \
    CMAKE_VERSION=3.24.2

# Update Ubuntu Software repository
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y \
      autoconf \
      automake \
      binutils \
      build-essential \
      ca-certificates \
      cmake \
      cpp \
      g++ \
      gcc \
      git-core \
      libboost-dev \
      libboost-filesystem-dev \
      libboost-program-options-dev \
      libboost-regex-dev \
      libboost-system-dev \
      libboost-thread-dev \
      libc6 \
      libcurl4-openssl-dev \
      libmysql++-dev \
      libpthread-stubs0-dev \
      libssl-dev \
      libtool \
      make \
      openssl \
      patch \
      pkg-config \
      unrar-free \
      unzip \
      wget \
      zlibc && \
    rm -rf /var/lib/apt/lists/*

# Prepare new cmake
RUN cd /tmp && wget --no-check-certificate https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    tar -xvzf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    mv /tmp/cmake-${CMAKE_VERSION}-linux-x86_64 /opt/cmake && \
    ln -s /opt/cmake/bin/* /usr/local/bin/ && \
    rm -f /tmp/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz

# Prepare Sources
RUN mkdir -p /opt/src && \
    git clone https://github.com/celguar/mangos-classic.git --branch ike3-bots /opt/src/cmangos && \
	git clone https://github.com/celguar/mangosbot-bots.git /opt/src/cmangos/src/modules/Bots && \
    echo "Core Version: ${ENV_CORE_COMMIT_HASH}" && \
    if [ "$ENV_CORE_COMMIT_HASH" != "HEAD" ]; then echo "Switching to Commit: ${ENV_CORE_COMMIT_HASH}\n"; cd /opt/src/cmangos; git checkout ${ENV_CORE_COMMIT_HASH}; fi

# Build Software
RUN mkdir -p /opt/cmangos/logs /opt/src/cmangos/build && \
    cd /opt/src/cmangos/build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/opt/cmangos -DBUILD_LOGIN_SERVER=ON -DBUILD_GAME_SERVER=OFF && \
    make -j 4 && make install

# Extract runtime files and cleanup
RUN rm -rfv /opt/src

# Download base image ubuntu
FROM ubuntu:20.04

# Install dependencies for running CMaNGOSd.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y \
    binutils \
    libboost-dev \
    libboost-filesystem1.71.0 \
    libboost-program-options1.71.0 \
    libboost-regex1.71.0 \
    libboost-system1.71.0 \
    libboost-thread1.71.0 \
    libc6 \
    libcurl4 \
    libmysql++3v5 \
    libpthread-stubs0-dev \
    libssl1.1 \
    libtool \
    openssl \
    pkg-config \
    tzdata \
    unrar-free \
    unzip \
    zlibc && \
    rm -rf /var/lib/apt/lists/*

# Copy over data
COPY --from=builder /opt/cmangos /opt/cmangos

# Fetch build arguments
ARG CORE_COMMIT_HASH=HEAD \
    DB_COMMIT_HASH=HEAD

# Set Timezone
ENV TZ=Europe/Amsterdam \
    ENV_CORE_COMMIT_HASH=$CORE_COMMIT_HASH \
    ENV_DB_COMMIT_HASH=$DB_COMMIT_HASH \
	DB_SERVER=database \
	DB_PORT=3306

# Volume configuration
VOLUME ["/opt/cmangos/etc"]

# Copy over init scripts and make them executable
COPY scripts/realmd.sh /opt/cmangos/scripts/realmd.sh
COPY scripts/wait-for-it.sh /opt/cmangos/scripts/wait-for-it.sh
RUN chmod +x /opt/cmangos/scripts/realmd.sh && chmod +x /opt/cmangos/scripts/wait-for-it.sh

# Prepare tini init
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
CMD ["/opt/cmangos/scripts/realmd.sh"]

# Expose ports
EXPOSE 3724