# Use ARG for OS and release (defaults to ubuntu and noble)
ARG os=ubuntu
ARG release=noble

# Base image
FROM ${os}:${release}
LABEL maintainer="Your Name <your.email@example.com>" # Update with your info

# Set DEBIAN_FRONTEND to noninteractive for the entire build
ENV DEBIAN_FRONTEND=noninteractive

# Set the timezone (optional, you can set it to your preferred timezone)
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    qgis \
    xpra \
    xvfb \
    libpam-sss \
    sssd-tools \
    sssd-ldap \
    sudo \
    vim \
    tzdata \
    gnupg \
    wget \
    software-properties-common \
    python3-pip \
    python3-venv \
    python3-pytest \
    python3-mock \
    xvfb \
    qttools5-dev-tools \
    pyqt5-dev-tools \
    && rm -rf /var/lib/apt/lists/*

# QGIS repository
ARG repo
ARG qgis_version=master

RUN wget -qO - https://qgis.org/downloads/qgis-2022.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import && \
    chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg && \
    # run twice because of https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1041012
    add-apt-repository "deb https://qgis.org/${repo} ${release} main" && \
    add-apt-repository "deb https://qgis.org/${repo} ${release} main" && \
    apt update

# Install QGIS (using the repo added above)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    qgis \
    python3-qgis \
    python3-qgis-common && \
    apt-get clean

# Create a non-root user (recommended for security)
RUN useradd -m -s /bin/bash qgisuser

# Switch to the non-root user
USER qgisuser

# Copy Xpra configuration
COPY ./xpra/xpra.conf /etc/xpra/xpra.conf

# Expose the Xpra port
EXPOSE 14500

# Create a wrapper script for Xpra
COPY start-xpra.sh /home/qgisuser/start-xpra.sh
RUN chmod +x /home/qgisuser/start-xpra.sh

# Command to start Xpra
CMD ["/home/qgisuser/start-xpra.sh"]
