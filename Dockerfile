FROM alpine:3.4

ARG TZ=UTC

ENV VERSION=0.4 \
    BUILDTIME_PKGS="alpine-sdk curl busybox bash rsync perl gd zlib libpng jpeg freetype mysql perl-plack findutils"

ADD docker-entrypoint.sh /

# Run-time Dependencies
RUN apk upgrade --update && \
    apk add tzdata && cp /usr/share/zoneinfo/$TZ /etc/timezone && apk del tzdata && \
    apk add --no-cache $BUILDTIME_PKGS && \
    chmod u+rx,g+rx,o+rx,a-w /docker-entrypoint.sh

CMD /docker-entrypoint.sh
