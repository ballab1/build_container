ARG FROM_BASE=${DOCKER_REGISTRY:-s2.ubuntu.home:5000/}${CONTAINER_OS:-alpine}/openjdk/${JAVA_VERSION:-11.0.15_p10-r0}:${BASE_TAG:-latest}
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=build_container
# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION

# include our project files
COPY build Dockerfile /tmp/

# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0

# kafka.broker version being bundled in this docker image
ARG COMPOSE_VERSION=2.17.3
LABEL version.kafka.docker_compose=$COMPOSE_VERSION
ARG LIBRDKAFKA_VERSION=2.1.1
LABEL version.librdkafka=$LIBRDKAFKA_VERSION
ARG FIXUID_VERSION=0.6.0
LABEL version.fixuid=$FIXUID_VERSION 
ARG GIT_CRYPT_VERSION=0.7.0
LABEL version.git_crypt=$GIT_CRYPT_VERSION 

ARG BUILDER_HOME=/home/builder

# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$DEBUG_TRACE" \
    && ([ "$DEBUG_TRACE" != 0 ] || rm -rf /tmp/*)

USER builder
WORKDIR /opt

ENTRYPOINT [ "docker-entrypoint.sh" ]
#CMD ["$CONTAINER_NAME"]
CMD ["build_container"]
