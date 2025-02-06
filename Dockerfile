# syntax=docker/dockerfile:1
ARG os=ubuntu
ARG release=noble
ARG QGIS_USER_UID=11000  # Default if not set via compose
ARG QGIS_USER_GID=11000

FROM ${os}:${release}

# Bring arguments into build stage
ARG QGIS_USER_UID
ARG QGIS_USER_GID

# System setup
RUN apt-get update && apt-get install -y --no-install-recommends \
    adduser \
    sudo \
    ca-certificates \
    wget \
    gnupg \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN addgroup --gid ${QGIS_USER_GID} qgisuser && \
    adduser --uid ${QGIS_USER_UID} --gid ${QGIS_USER_GID} \
        --disabled-password --gecos "" --home /home/qgisuser qgisuser

# Install remaining system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    xkb-data \
    x11-xkb-utils \
    libglx0 \
    libgl1 \
    libglu1-mesa \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*

#Fix Dbus and Python Module Errors
RUN apt-get update && apt-get install -y \
    dbus \
    dbus-x11 \
    xdg-utils \
    python3-dbus \
    python3-gst-1.0 \
    python3-zeroconf \
    python3-xdg \
    fuse3 \
    libfuse3-3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure QGIS repository
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO /etc/apt/keyrings/qgis-archive-keyring.gpg \
    https://download.qgis.org/downloads/qgis-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://qgis.org/debian noble main" \
    > /etc/apt/sources.list.d/qgis.list

# Add Xpra repository
RUN wget -q https://xpra.org/gpg.asc -O- | gpg --dearmor > /etc/apt/trusted.gpg.d/xpra.gpg && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/xpra.gpg] https://xpra.org/ noble main" \
    > /etc/apt/sources.list.d/xpra.list

# Install application stack
RUN apt-get update && apt-get install -y --no-install-recommends \
    qgis \
    qgis-plugin-grass \
    xpra \
    xpra-x11 \
    xpra-html5 \
    python3-pip \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Configure runtime environment
RUN mkdir -p \
    /tmp/.X11-unix \
    /run/user/${QGIS_USER_UID}/xpra \
    #&& chmod 1777 /tmp/.X11-unix \
    && chmod 1700 /tmp/.X11-unix \
    && chown -R qgisuser:qgisuser /run/user/${QGIS_USER_UID} \
    && chown -R root:root /tmp/.X11-unix

# File transfer directories
RUN mkdir -p /home/qgisuser/uploads /home/qgisuser/downloads \
    && chown -R qgisuser:qgisuser /home/qgisuser \
    && chmod 700 /home/qgisuser/uploads /home/qgisuser/downloads


# Fix runtime directory permissions
RUN mkdir -p /run/user/${QGIS_USER_UID} && \
    chmod 700 /run/user/${QGIS_USER_UID} && \
    chown qgisuser:qgisuser /run/user/${QGIS_USER_UID}

# Create Xpra socket directory
RUN mkdir -p /run/xpra && \
    chmod 700 /run/xpra

# Copy startup script
COPY xpra/start-xpra.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-xpra.sh

# Add Xpra configuration file (xpra.conf)
COPY xpra/xpra.conf /etc/xpra/xpra.conf

# Final configuration
USER qgisuser
ENV LIBGL_ALWAYS_SOFTWARE=1 \
    XDG_RUNTIME_DIR=/run/user/${QGIS_USER_UID} \
    DISPLAY=:99 \
    QGIS_UPLOAD_DIR=/home/qgisuser/uploads \
    QGIS_DOWNLOAD_DIR=/home/qgisuser/downloads

EXPOSE 14500
CMD ["/usr/local/bin/start-xpra.sh"]
