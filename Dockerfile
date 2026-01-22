FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV HOME=/root

# ===============================
# Install Required Packages
# ===============================
RUN apt update && apt install -y \
    obs-studio \
    xvfb \
    x11vnc \
    openbox \
    novnc \
    websockify \
    ca-certificates \
    fonts-dejavu \
    mesa-utils \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# ===============================
# noVNC default page
# ===============================
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ===============================
# Entry Script
# ===============================
RUN cat << 'EOF' > /entrypoint.sh
#!/bin/bash
set -e

export DISPLAY=:1

echo "Starting Xvfb..."
Xvfb :1 -screen 0 1280x720x16 -nolisten tcp -ac +extension GLX +render &

sleep 2

echo "Starting Openbox..."
openbox &

sleep 2

echo "Starting OBS..."
obs \
  --disable-shutdown-check \
  --minimize-to-tray \
  --disable-updater &

sleep 3

echo "Starting x11vnc..."
x11vnc \
  -display :1 \
  -nopw \
  -forever \
  -shared \
  -noxdamage \
  -ncache 10 \
  -ncache_cr \
  -wait 5 \
  -defer 5 \
  -repeat \
  -tight \
  -compresslevel 0 \
  -quality 6 \
  -rfbport 5900 &

echo "Starting noVNC on port 8080..."
websockify \
  --web=/usr/share/novnc/ \
  --heartbeat=30 \
  --timeout=300 \
  0.0.0.0:8080 localhost:5900
EOF

RUN chmod +x /entrypoint.sh

# ===============================
# Expose Port (Koyeb / HF)
# ===============================
EXPOSE 8080

CMD ["/entrypoint.sh"]
