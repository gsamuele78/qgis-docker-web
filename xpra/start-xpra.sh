#!/bin/bash

# Ensure the XPRA_PASSWORD environment variable is set
if [ -z "$XPRA_PASSWORD" ]; then
  echo "XPRA_PASSWORD environment variable is not set. Exiting."
  exit 1
fi

# Export the XPRA_PASSWORD environment variable for use by xpra
export XPRA_PASSWORD

# Echo the XPRA_PASSWORD for debugging purposes
echo "XPRA_PASSWORD is set."

# Start Xvfb (X virtual framebuffer) to create a virtual display
Xvfb ${DISPLAY} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &

# Start the xpra server with specified options
xpra start \
  --bind-tcp=0.0.0.0:${XPRA_PORT} \
  --html=on \
  --start-child="dbus-launch qgis" \
  --exit-with-children=yes \
  --file-transfer=on \
  --resize-display=yes \
  --desktop-scaling=auto \
  --dbus-control=yes \
  --pulseaudio=no \
  --audio=no \
  --mdns=no \
  --webcam=no \
  --notifications=no \
  --socket-dirs=/run/user/${QGIS_USER_UID}/xpra \
  --clipboard=yes \
  --auth=env \
  --daemon=no \
  2> >(grep -vE "Could not resolve keysym|ZINK" >&2)

  #--auth=env:name=${XPRA_PASSWORD} \
