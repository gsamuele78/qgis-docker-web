#!/bin/bash
# Use the existing user's UID/GID from container runtime
XPRA_UID=$(id -u)
XPRA_GID=$(id -g)

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


## Create runtime directories in container
#mkdir -p ${XDG_RUNTIME_DIR} && chmod 700 ${XDG_RUNTIME_DIR}
#mkdir -p /home/qgisuser/uploads /home/qgisuser/downloads
#chmod 755 /home/qgisuser/uploads /home/qgisuser/downloads
## Ensure runtime directories exist
#mkdir -p ${XDG_RUNTIME_DIR} && chmod 700 ${XDG_RUNTIME_DIR}

## Start Xvfb in the background
#Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
#
## Start Xpra with file transfer capabilities
#DISPLAY=:99 exec xpra start \
#  --bind-tcp=0.0.0.0:${XPRA_PORT} \
#  --html=on \
#  --file-transfer=auto \
# # --open-files=auto \
# # --open-url=auto \ 
#  --debug  server+keyboard \
#  --start-child="dbus-launch qgis" \
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
#  --file-size-limit=${XPRA_FILE_SIZE_LIMIT} \
#  --xvfb="Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset" \ 
#  2> >(grep -vE "Could not resolve keysym|ZINK" >&2)
#
## Keep container running
#tail -f /dev/null

Xvfb ${DISPLAY} -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &

xpra start \
  --bind-tcp=0.0.0.0:${XPRA_PORT} \
  --html=on \
  --start-child="qgis" \
  --exit-with-children=yes \
  --file-transfer=on \
  --resize-display=yes \
  --dbus-control=yes \
  --headerbar=auto \
  --opengl=auto \
  --pulseaudio=no \
  --audio=no \
  --mdns=no \
  --webcam=no \
  --notifications=no \
  --socket-dirs=/run/user/${QGIS_USER_UID}/xpra \
  --clipboard=yes \
  --auth=file:filename=${XPRA_PASSWORD_FILE:-/dev/null} \
  --daemon=no \
  --uid=${XPRA_UID} \
  --gid=${XPRA_GID} \
  2> >(grep -vE "Could not resolve keysym|ZINK" >&2)

tail -f /dev/null


