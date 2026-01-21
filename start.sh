#!/bin/bash

# Start virtual display
Xvfb :1 -screen 0 1280x720x24 &

sleep 2

# Window manager
fluxbox &

# Start OBS
obs &

# VNC server
x11vnc -display :1 -nopw -forever -shared &

# noVNC Web
websockify --web=/usr/share/novnc/ 0.0.0.0:8080 localhost:5900
