#!/bin/bash
# Use the existing user's UID/GID from container runtime
#XPRA_UID=$(id -u)
#XPRA_GID=$(id -g)

#Xvfb ${DISPLAY} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &

#xpra start \
#  --bind-tcp=0.0.0.0:${XPRA_PORT} \
#  --html=on \
#  --start-child="qgis" \
#  --exit-with-children=yes \
#  --speaker=off \
#  --microphone=off \
#  --pulseaudio=no \
#  --audio=no \
#  --mdns=no \
#  --webcam=no \
#  --notifications=no \
#  --socket-dirs=/run/user/${QGIS_USER_UID}/xpra \
#  --clipboard=yes \
#  --auth=file:filename=${XPRA_PASSWORD_FILE:-/dev/null} \
#  --daemon=no \
# # --uid=${XPRA_UID} \       # Get from current user
# # --gid=${XPRA_GID} \       # Get from current user
#  2> >(grep -vE "Could not resolve keysym|ZINK" >&2)
#
#tail -f /dev/null

# Ensure runtime directories exist
mkdir -p ${XDG_RUNTIME_DIR} && chmod 700 ${XDG_RUNTIME_DIR}

# Start Xvfb in the background
Xvfb ${DISPLAY} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &

# Start Xpra with DBUS fixed
exec xpra start \
  --bind-tcp=0.0.0.0:${XPRA_PORT} \
  --html=on \
  --start-child="dbus-launch qgis" \
  --exit-with-children=yes \
  --speaker=off \
  --microphone=off \
  --pulseaudio=no \
  --audio=no \
  --mdns=no \
  --webcam=no \
  --notifications=no \
  --socket-dirs=/run/user/${QGIS_USER_UID}/xpra \
  --clipboard=yes \
  --auth=file:filename=${XPRA_PASSWORD_FILE:-/dev/null} \
  --daemon=no \
  2> >(grep -vE "Could not resolve keysym|ZINK" >&2)

# Keep container running
tail -f /dev/null
