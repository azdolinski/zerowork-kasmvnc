FROM lscr.io/linuxserver/webtop:ubuntu-xfce


ARG DEBIAN_FRONTEND=noninteractive
USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    curl \
    nano \
    htop \
    libnss3 \
    libxss1 \
    software-properties-common \
    && apt-get clean

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update && apt-get install -y google-chrome-stable

# Download and install ZeroWork .deb package
RUN wget https://zerowork-agent-releases.s3.amazonaws.com/public/linux/ZeroWork-1.1.56.deb -O /tmp/ZeroWork-1.1.56.deb \
    && apt-get install -y /tmp/ZeroWork-1.1.56.deb \
    && rm /tmp/ZeroWork-1.1.56.deb

RUN mkdir -p /etc/s6-overlay/s6-rc.d/svc-zerowork && \
(echo '#!/usr/bin/with-contenv bash'; \
echo 'exec s6-setuidgid abc /opt/ZeroWork/zerowork'; \
) >> /etc/s6-overlay/s6-rc.d/svc-zerowork/run && \
echo "longrun" >> /etc/s6-overlay/s6-rc.d/svc-zerowork/type && \
mkdir -p /etc/s6-overlay/s6-rc.d/svc-zerowork/dependencies.d && \
touch /etc/s6-overlay/s6-rc.d/svc-zerowork/dependencies.d/svc-kasmvnc && \
touch /etc/s6-overlay/s6-rc.d/user/contents.d/svc-zerowork