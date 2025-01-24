# Use ARG for OS and release (defaults to ubuntu and noble)
ARG os=ubuntu
ARG release=noble
ARG PUID=1000
ARG PGID=1000

# Base image
FROM ${os}:${release}
LABEL maintainer="Your Name <your.email@example.com>" 

# Set DEBIAN_FRONTEND to noninteractive for the entire build
ENV DEBIAN_FRONTEND=noninteractive

# Set the timezone (optional, you can set it to your preferred timezone)
ENV TZ=UTC
ENV LC_ALL=C.UTF-8

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create user with specified UID/GID
#RUN groupadd -g ${PGID} qgisuser && \
#RUN useradd -u ${PUID} -g ${PGID} -m -s /bin/bash qgisuser
#RUN useradd -u 1000 -g 1000 -m -s /bin/bash qgisuser
#RUN useradd -m -s /bin/bash qgisuser

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    gnupg \
    gpg-agent && \
    rm -rf /var/lib/apt/lists/*

# Configure QGIS repository
RUN mkdir -p /etc/apt/keyrings && \
    # Download QGIS GPG key directly (already in binary format)
    wget -qO /etc/apt/keyrings/qgis-archive-keyring.gpg \
    https://download.qgis.org/downloads/qgis-archive-keyring.gpg && \
    # Verify key integrity
    gpg --no-default-keyring --keyring /etc/apt/keyrings/qgis-archive-keyring.gpg --list-keys && \
    # Set proper permissions
    chmod 644 /etc/apt/keyrings/qgis-archive-keyring.gpg && \
    # Add repository with signed-by directive
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://qgis.org/debian noble main" | \
    tee /etc/apt/sources.list.d/qgis.list



# Install dependencies
RUN apt-get update && apt-get install -y \
    qgis \
#    qgis-plugin-grass-common \
#    qgis-common \
    qgis-plugin-grass \
    xpra \
    xvfb \
    libpam-sss \
    sssd-tools \
    sssd-ldap \
    sudo \
    vim \
    tzdata \
 #   gnupg \
 #   wget \
 #   software-properties-common \
    python3-pip \   
    python3-venv \
    python3-pytest \
    python3-mock \
    xvfb \
    qttools5-dev-tools \
    pyqt5-dev-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user (recommended for security)
#RUN useradd -m -s /bin/bash qgisuser

# Copy Xpra configuration
#COPY ./xpra/xpra.conf /etc/xpra/xpra.conf

# Create a wrapper script for Xpra
#RUN mkdir -p /home/qgisuser/data && \
#    chown -R qgisuser:qgisuser /home/qgisuser

#COPY ./xpra/start-xpra.sh /home/qgisuser/start-xpra.sh
COPY ./xpra/start-xpra.sh /usr/bin/start-xpra.sh
#RUN chmod +x /home/qgisuser/start-xpra.sh
RUN chmod +x /usr/bin/start-xpra.sh



# Switch to the non-root user
#USER qgisuser

# Copy Xpra configuration
COPY ./xpra/xpra.conf /etc/xpra/xpra.conf


# Expose the Xpra port
EXPOSE 14500

# Command to start Xpra
CMD ["/bin/bash", "/usr/bin/start-xpra.sh"]
