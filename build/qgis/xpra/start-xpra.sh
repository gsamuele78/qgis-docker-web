#!/bin/bash

# Ensure the XPRA_PASSWORD environment variable is set
if [ -z "$XPRA_PASSWORD" ]; then
  echo "XPRA_PASSWORD environment variable is not set. Exiting."
  exit 1
fi

# Export the XPRA_PASSWORD environment variable for use by xpra
export XPRA_PASSWORD

# Get the username from the environment variable or use a default
USER_NAME=${USER_NAME:-qgisuser}

# Create a user-specific home directory within /home/qgisuser/users
#USER_HOME="/home/qgisuser/users/${USER_NAME}"
#mkdir -p ${USER_HOME}
#chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}

# Echo the XPRA_PASSWORD for debugging purposes
echo "XPRA_PASSWORD is set."

# Start Xvfb (X virtual framebuffer) to create a virtual display
#Xvfb ${DISPLAY} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &

# Function to start QGIS with xpra
start_qgis() {
  xpra start \
    --bind-tcp=0.0.0.0:${XPRA_PORT} \
    --start-child="dbus-launch qgis" \
    --dbus-control=yes \
    --mdns=no \
    --exit-with-children=no \
    --html=on \
    --daemon=no \
    --xvfb="/usr/bin/Xvfb ${DISPLAY} -screen 0 1920x1080x24+32 -ac +extension GLX +render -nolisten tcp -noreset" \
    --pulseaudio=no \
    --notifications=no \
    --audio=no \
    --webcam=no \
    --bell=no \
    --socket-dirs=/run/user/${QGIS_USER_UID}/xpra \
    --clipboard=yes \
    2> >(grep -vE "Could not resolve keysym|ZINK" >&2)
    #--auth=env:name=${XPRA_PASSWORD} \
}

# Function to monitor QGIS and restart if it exits
monitor_qgis() {
  while true; do
    if ! pgrep -f "qgis.bin" > /dev/null; then
      echo "QGIS has exited. Restarting..."
      start_qgis
    fi
    sleep 5
  done
}

# Start QGIS for the first time
start_qgis

# Start monitoring QGIS
monitor_qgis &

# Keep the script running
#tail -f /dev/null
