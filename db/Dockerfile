# Download base image ubuntu 20.04
FROM mariadb

# Fetch build arguments
ARG CORE_COMMIT_HASH=HEAD \
    DB_COMMIT_HASH=HEAD

# Set Timezone and Build arguments
ENV TZ=Europe/Amsterdam \
    ENV_CORE_COMMIT_HASH=$CORE_COMMIT_HASH \
    ENV_DB_COMMIT_HASH=$DB_COMMIT_HASH
	
RUN mkdir -p /opt/cmangos/etc

# Install Software
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y \
     ca-certificates \
     git \
     tzdata && \
    rm -rf /var/lib/apt/lists/*