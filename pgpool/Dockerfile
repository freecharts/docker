# Copyright FreeCharts.
# SPDX-License-Identifier: MIT License

ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=13.4-slim
ARG PGPOOL_VERSION=4.6.1-2

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}
LABEL author="https://github.com/papieric"
LABEL orgamnization="FreeCharts"
LABEL organization.url="https://github.com/freecharts"
LABEL description="Pgpool-II is a middleware that works between PostgreSQL servers and a PostgreSQL database client. It provides connection pooling, replication, load balancing, and automatic failover capabilities for PostgreSQL databases."

ARG PGPOOL_VERSION

ENV USER=pgpool \
    UID=999 \
    PGPOOL_DATA=/opt/pgpool

ENV GROUP=${USER} \
    GID=${UID}

# Install pgpool2 runtime package and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    pgpool2=${PGPOOL_VERSION} \
    postgresql-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create pgpool runtime group and user, then directory structure
RUN groupadd -g ${GID} ${GROUP} && \
    useradd -u ${UID} -g ${GROUP} -m -d ${PGPOOL_DATA} -s /bin/bash ${USER} && \
    mkdir -p ${PGPOOL_DATA}/conf ${PGPOOL_DATA}/run ${PGPOOL_DATA}/var && \
    chown -R ${UID}:${GID} ${PGPOOL_DATA} && \
    chmod 700 ${PGPOOL_DATA}

# Copy configuration templates
COPY conf/* ${PGPOOL_DATA}/conf/

# Set proper permissions on config files
RUN chown ${UID}:${GID} ${PGPOOL_DATA}/conf/*.conf && \
    chmod 600 ${PGPOOL_DATA}/conf/*.conf

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
    CMD /usr/bin/pg_isready -p 5432 -h localhost || exit 1

EXPOSE 5432
WORKDIR ${PGPOOL_DATA}
USER ${USER}

CMD ["/usr/sbin/pgpool", "-n", "-f", "/opt/pgpool/conf/pgpool.conf"]

