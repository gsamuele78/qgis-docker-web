FROM ubuntu:22.04

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
    && rm -rf /var/lib/apt/lists/*

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
