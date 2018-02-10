ARG CODE_VERSION=base_container:20180210
FROM $CODE_VERSION

ENV VERSION=1.0.0    
LABEL version=$VERSION

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/container/build.sh \
    && /tmp/container/build.sh 'ALPINEFULL'
RUN rm -rf /tmp/*

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["alpinefull"]
