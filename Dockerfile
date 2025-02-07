# syntax=docker/dockerfile:1
# Define build arguments for the OS and release version
ARG os=ubuntu
ARG release=noble

# Default user UID and GID, these can be overridden by Docker Compose
ARG QGIS_USER_UID=11000 
ARG QGIS_USER_GID=11000

# Use the specified OS and release version as the base image
FROM ${os}:${release}

# Bring build arguments into the build stage
ARG QGIS_USER_UID
ARG QGIS_USER_GID

# Install system utilities and dependencies for adding users and certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    adduser \
    sudo \
    ca-certificates \
    wget \
    gnupg \
    apt-transport-https

# Remove the default 'ubuntu' user if it exists to avoid UID/GID conflicts
RUN if id "ubuntu" &>/dev/null; then userdel -r ubuntu; fi

# Create the 'qgisuser' with the specified UID and GID
RUN addgroup --gid ${QGIS_USER_GID} qgisuser && \
    adduser --uid ${QGIS_USER_UID} --gid ${QGIS_USER_GID} \
    --disabled-password --gecos "" --home /home/qgisuser qgisuser

# Install additional system dependencies required for QGIS and Xpra
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    xkb-data \
    x11-xkb-utils \
    libglx0 \
    libgl1 \
    libglu1-mesa \
    mesa-utils \
    dbus \
    dbus-x11 \
    xdg-utils \
    python3-dbus \
    python3-gst-1.0 \
    python3-zeroconf \
    python3-xdg \
    fuse3 \
    libfuse3-3

# Configure QGIS repository and import the signing key
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO /etc/apt/keyrings/qgis-archive-keyring.gpg \
    https://download.qgis.org/downloads/qgis-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://qgis.org/debian noble main" \
    > /etc/apt/sources.list.d/qgis.list

# Add Xpra repository and import the signing key
RUN wget -q https://xpra.org/gpg.asc -O- | gpg --dearmor > /etc/apt/trusted.gpg.d/xpra.gpg && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/xpra.gpg] https://xpra.org/ noble main" \
    > /etc/apt/sources.list.d/xpra.list

# Install QGIS, Xpra, and Python dependencies, then clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
    qgis \
    qgis-plugin-grass \
    xpra \
    xpra-x11 \
    xpra-html5 \
    python3-pip && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Configure runtime environment directories and permissions
RUN mkdir -p \
    /tmp/.X11-unix \
    /run/user/${QGIS_USER_UID}/xpra && \
    chmod 1700 /tmp/.X11-unix && \
    chmod -R 700 /run/user/${QGIS_USER_UID} && \
    chown -R qgisuser:qgisuser /run/user/${QGIS_USER_UID} && \
    chown -R root:root /tmp/.X11-unix

# Copy the Xpra startup script and set execute permissions
COPY xpra/start-xpra.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-xpra.sh

# Add the Xpra configuration file
COPY xpra/xpra.conf /etc/xpra/xpra.conf

# Switch to 'qgisuser' for running the container
USER qgisuser

# Set environment variables for the runtime environment
ENV LIBGL_ALWAYS_SOFTWARE=1 \
    XDG_RUNTIME_DIR=/run/user/${QGIS_USER_UID} \
    DISPLAY=:99 

# Expose the port for Xpra
EXPOSE 14500

# Set the default command to start Xpra
CMD ["/usr/local/bin/start-xpra.sh"]
