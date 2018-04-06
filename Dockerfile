ARG FROM_BASE=base_container:20180329
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=alpinefull
ARG CONTAINER_VERSION=1.0.8

LABEL org_name=$CONTAINER_NAME \
      version=$CONTAINER_VERSION 

# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ARG DEBUG_TRACE=0
# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION=${CBF_VERSION:-v2.0}
# inclide our project files
COPY build /tmp/


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME"
RUN [ $DEBUG_TRACE != 0 ] || rm -rf /tmp/* \n 


ENTRYPOINT [ "docker-entrypoint.sh" ]
#CMD ["$CONTAINER_NAME"]
CMD ["alpinefull"]
