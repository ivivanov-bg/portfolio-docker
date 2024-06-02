# Pull base image.
#FROM jlesage/baseimage-gui:alpine-3.19-v4 AS base
FROM jlesage/baseimage-gui:ubuntu-18.04-v4 AS base

RUN install-glibc

# System config
RUN apk --no-cache add ca-certificates wget curl && update-ca-certificates && \
    add-pkg \
		openjdk21-jre \
		gtk+3.0 \
		dbus-x11 \
		dbus \
		webkit2gtk



FROM base as app

# ENV vars
ARG VERSION
ARG TARGETPLATFORM

# ENV ARCHITECTURE $ARCHITECTURE
ENV APP_NAME=${APP_NAME:-"Portfolio Performance"}


# Download & install App
## if $VERSION is not set via --build-arg -> fetch latest PP version
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=x86_64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE=arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=amd64; fi \
    && export VERSION=${VERSION:-$(curl --silent "https://api.github.com/repos/portfolio-performance/portfolio/releases/latest" |grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')} \
    && cd /opt && wget https://github.com/portfolio-performance/portfolio/releases/download/${VERSION}/PortfolioPerformance-${VERSION}-linux.gtk.${ARCHITECTURE}.tar.gz \
    && tar xvzf PortfolioPerformance-${VERSION}-linux.gtk.${ARCHITECTURE}.tar.gz \
    && rm PortfolioPerformance-${VERSION}-linux.gtk.${ARCHITECTURE}.tar.gz

# ENV vars
ARG LOCALE
ENV APP_ICON_URL=https://www.portfolio-performance.info/images/logo.png

# Configure App
## if $LOCALE is not set via --build-arg -> use en_US locale
RUN sed -i '1s;^;-configuration\n/opt/portfolio/configuration\n-data\n/opt/portfolio/workspace\n;' /opt/portfolio/PortfolioPerformance.ini && \
	echo "osgi.nl=${LOCALE:-"en_US"}" >> /opt/portfolio/configuration/config.ini && \
	chmod -R 777 /opt/portfolio && \
	install_app_icon.sh "$APP_ICON_URL"

# Copy files to container
ADD rootfs /

