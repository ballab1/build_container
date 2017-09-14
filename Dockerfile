FROM alpine:3.6

ARG TZ=UTC

ENV VERSION=0.4 \
    BUILDTIME_PKGS="alpine-sdk linux-headers curl busybox bash rsync perl gd zlib libpng jpeg freetype mysql perl-plack findutils"

ADD docker-entrypoint.sh /

# Run-time Dependencies
RUN set -e \
    && apk update \
    && apk add --no-cache $BUILDTIME_PKGS \
    && echo "$TZ" > /etc/TZ \
    && cp /usr/share/zoneinfo/$TZ /etc/timezone \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && chmod u+rx,g+rx,o+rx,a-w /docker-entrypoint.sh

CMD /docker-entrypoint.sh
