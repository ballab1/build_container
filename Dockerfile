FROM alpine:3.6

ARG TZ=UTC

ENV VERSION=0.4 \
    BUILDTIME_PKGS="alpine-sdk linux-headers curl busybox bash rsync perl gd zlib libpng jpeg freetype mysql perl-plack findutils" \
    CORE_PKGS="coreutils git openssh-client curl unzip bash ttf-dejavu alpine-sdk bash-completion supervisor shadow libxml2-dev" \
    NAGIOS_PKGS="busybox rsync perl gd zlib libpng jpeg freetype mysql perl-plack" \
    OTHER_PKGS="gd-dev libpng-dev jpeg-dev"    

ADD docker-entrypoint.sh /

# Run-time Dependencies
RUN set -e \
    && apk update \
    && apk add --no-cache $BUILDTIME_PKGS $CORE_PKGS $OTHER_PKGS \
    && echo "$TZ" > /etc/TZ \
    && cp /usr/share/zoneinfo/$TZ /etc/timezone \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && chmod u+rx,g+rx,o+rx,a-w /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
