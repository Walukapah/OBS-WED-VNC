FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Install OBS + GUI + noVNC
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

# noVNC default page
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ---- CREATE start.sh INSIDE DOCKERFILE ----
RUN cat << 'EOF' > /start.sh
#!/bin/bash
set -e

echo "Starting virtual display..."
Xvfb :1 -screen 0 1280x720x24 &

sleep 2

echo "Starting window manager..."
fluxbox &

sleep 2

echo "Starting OBS Studio..."
obs &

sleep 2

echo "Starting VNC server..."
x11vnc -display :1 -nopw -forever -shared &

echo "Starting noVNC web server..."
websockify --web=/usr/share/novnc/ 0.0.0.0:8080 localhost:5900
EOF

RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
