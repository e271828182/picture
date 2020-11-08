FROM openjdk:11-jre-slim

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

ARG kafka_version=2.5.0
ARG scala_version=2.12

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka

ARG DISTRO_NAME="kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz"

# Download Apache kafka, untar and clean up
RUN set -eux; \
    wget -q -O "/tmp/$DISTRO_NAME" "https://downloads.apache.org/kafka/$KAFKA_VERSION/$DISTRO_NAME"; \
    tar xfz /tmp/$DISTRO_NAME -C /opt; \
    rm /tmp/$DISTRO_NAME; \
    ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME}

COPY conf/server.properties /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/config/server.properties

EXPOSE 9092

WORKDIR $KAFKA_HOME

CMD ["bin/kafka-server-start.sh", "config/server.properties"]

