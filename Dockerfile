FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Basic packages + OBS + X11 + noVNC
RUN apt update && apt install -y \
    obs-studio \
    xvfb \
    x11vnc \
    fluxbox \
    novnc \
    websockify \
    supervisor \
    wget \
    curl \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# noVNC web files
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
