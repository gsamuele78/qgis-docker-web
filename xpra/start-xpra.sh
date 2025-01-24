#!/bin/bash
# Start Xpra using the configuration file
#xpra start --config=/etc/xpra/xpra.conf --uid=$QGIS_USER_UID --gid=$QGIS_USER_GID
xpra start --uid=$QGIS_USER_UID --gid=$QGIS_USER_GID
