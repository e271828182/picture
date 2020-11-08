FROM openjdk:8-jre-slim

LABEL maintainer="star"

# Install required packges
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        dirmngr \
        gosu \
        gnupg \
        netcat \
        file \
        inetutils-ping \
        wget; \
    rm -rf /var/lib/apt/lists/*; \
# Verify that gosu binary works
    gosu nobody true

COPY canal.deployer-1.1.4.tar.gz /tmp/

# Download Apache kafka, untar and clean up
RUN set -eux; \
    mkdir /usr/local/canal; \
    tar -xf /tmp/canal.deployer-1.1.4.tar.gz -C /usr/local/canal

WORKDIR /usr/local/canal

CMD ["bin/startup.sh"]

