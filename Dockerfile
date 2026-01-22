FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV HOME=/root

Install required packages

RUN apt update && apt install -y \
obs-studio \
xvfb \
x11vnc \
openbox \
novnc \
websockify \
ca-certificates \
fonts-dejavu \
&& rm -rf /var/lib/apt/lists/*

noVNC default page

RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

Create startup script inside Dockerfile

RUN cat << 'EOF' > /entrypoint.sh
#!/bin/bash
set -e

echo "Starting Xvfb..."
Xvfb :1 -screen 0 1280x720x24 &

sleep 2

echo "Starting Openbox..."
openbox &

sleep 2

echo "Starting OBS..."
obs --disable-shutdown-check &

sleep 3

echo "Starting x11vnc..."
x11vnc -display :1 -nopw -forever -shared &

echo "Starting noVNC on port 8080..."
websockify --web=/usr/share/novnc/ 0.0.0.0:8080 localhost:5900
EOF

RUN chmod +x /entrypoint.sh

Koyeb requires fixed exposed port

EXPOSE 8080

CMD ["/entrypoint.sh"]
