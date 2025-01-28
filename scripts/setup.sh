#!/bin/bash

# --- Configuration (from .env) ---
set -a # Automatically export variables
source .env
set +a

# --- Directories ---
mkdir -p data/storage log
mkdir -p nginx/ssl/self-signed
mkdir -p nginx/ssl/duckdns

# --- User Permissions ---
# Ensure the data and log directories are owned by the user specified in .env
chown -R ${QGIS_USER_UID}:${QGIS_USER_GID} data log

# --- Join Active Directory (if not already joined) ---
#if ! realm list | grep -q "pippo.pluto.com"; then
#  echo "Joining Active Directory domain pippo.pluto.com..."
#  sudo apt update
#  sudo apt install -y realmd sssd sssd-tools adcli krb5-user samba-common-bin oddjob-mkhomedir packagekit
#  sudo realm discover pippo.pluto.com
#  echo "Enter the Active Directory admin username when prompted."
#  sudo realm join --user=<admin_user> pippo.pluto.com # Replace <admin_user>
#  echo "session optional pam_mkhomedir.so skel=/etc/skel/ umask=0022" | sudo tee -a /etc/pam.d/common-session
#  # Optional: Restrict SSH access (uncomment if needed)
#  # echo "AllowGroups \"Domain Users\"" | sudo tee -a /etc/ssh/sshd_config
#  # sudo systemctl restart sshd
#  echo "Rebooting in 60 seconds to complete domain join..."
#  sudo shutdown -r +1
#fi

# --- Nginx SSL Configuration ---
echo "Choose SSL certificate type:"
select ssl_type in "Let's Encrypt (Certbot)" "DuckDNS (Certbot)" "Self-Signed"; do
  case $ssl_type in
    "Let's Encrypt (Certbot)")
      echo "Setting up Let's Encrypt certificate with Certbot..."
      # Install Certbot
      sudo snap install core && sudo snap refresh core
      sudo snap install --classic certbot
      sudo ln -s /snap/bin/certbot /usr/bin/certbot
      # Stop Nginx temporarily
      docker-compose -f docker-compose.yml stop nginx
      # Obtain certificate
      sudo certbot certonly --standalone -d ${DOMAIN_NAME}
      # Update nginx.conf (Let's Encrypt) 
      sed -i "s|listen       80;|listen       443 ssl;|" nginx/nginx.conf
      sed -i "s|server_name  .*;|server_name  ${DOMAIN_NAME};|" nginx/nginx.conf
      sed -i "s|# Redirect HTTP to HTTPS|# Redirect HTTP to HTTPS\n        if (\$scheme = http) {\n            return 301 https://\$server_name\$request_uri;\n        }|" nginx/nginx.conf
      sed -i "/server_name  ${DOMAIN_NAME};/a \        ssl_certificate     /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;" nginx/nginx.conf
      sed -i "/ssl_certificate     \/etc\/letsencrypt\/live\/${DOMAIN_NAME}\/fullchain.pem;/a \        ssl_certificate_key /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;" nginx/nginx.conf
      # Update docker-compose.yml (Let's Encrypt)
      sed -i "s|      - \"\${NGINX_PORT}:80\"|      - \"\${NGINX_PORT}:443\"\n      - \"80:80\"|" docker-compose.yml
      sed -i "/- \${PWD}\/log\/nginx.log:\/var\/log\/nginx\/access.log/a \      - /etc/letsencrypt:/etc/letsencrypt:ro" docker-compose.yml
      # Set up renewal cron job
      echo "0 0 * * * certbot renew --nginx --post-hook \"docker-compose -f docker-compose.yml up -d nginx\"" | sudo tee /etc/cron.d/certbot-renewal
      break
      ;;
    "DuckDNS (Certbot)")
      echo "Setting up DuckDNS certificate with Certbot..."
      # Install DuckDNS plugin
      sudo apt install python3-certbot-dns-duckdns
      # Get DuckDNS token (prompt user)
      read -r -p "Enter your DuckDNS API token: " DUCKDNS_TOKEN
      # Create credentials file
      sudo mkdir -p /etc/duckdns
      echo "dns_duckdns_token = $DUCKDNS_TOKEN" | sudo tee /etc/duckdns/duckdns.ini
      sudo chmod 600 /etc/duckdns/duckdns.ini
      # Stop Nginx temporarily
      docker-compose -f docker-compose.yml stop nginx
      # Obtain certificate
      sudo certbot certonly \
        --dns-duckdns \
        --dns-duckdns-credentials /etc/duckdns/duckdns.ini \
        -d *.${DOMAIN_NAME} \
        --post-hook "docker-compose -f docker-compose.yml up -d nginx"
      # Update nginx.conf (DuckDNS)
      sed -i "s|listen       80;|listen       443 ssl;|" nginx/nginx.conf
      sed -i "s|server_name  .*;|server_name  *.${DOMAIN_NAME};|" nginx/nginx.conf
      sed -i "s|# Redirect HTTP to HTTPS|# Redirect HTTP to HTTPS\n        if (\$scheme = http) {\n            return 301 https://\$server_name\$request_uri;\n        }|" nginx/nginx.conf
      sed -i "/server_name  *.${DOMAIN_NAME};/a \        ssl_certificate     /etc/letsencrypt/live/*.${DOMAIN_NAME}/fullchain.pem;" nginx/nginx.conf
      sed -i "/ssl_certificate     \/etc\/letsencrypt\/live\/\*\.${DOMAIN_NAME}\/fullchain.pem;/a \        ssl_certificate_key /etc/letsencrypt/live/*.${DOMAIN_NAME}/privkey.pem;" nginx/nginx.conf
      # Update docker-compose.yml (DuckDNS)
      sed -i "s|      - \"\${NGINX_PORT}:80\"|      - \"\${NGINX_PORT}:443\"\n      - \"80:80\"|" docker-compose.yml
      sed -i "/- \${PWD}\/log\/nginx.log:\/var\/log\/nginx\/access.log/a \      - /etc/letsencrypt:/etc/letsencrypt:ro" docker-compose.yml
      sed -i "/- \/etc\/letsencrypt:\/etc\/letsencrypt:ro/a \      - /etc/duckdns:/etc/duckdns:ro" docker-compose.yml
      # Set up renewal cron job
      echo "0 0 * * * certbot renew --nginx --post-hook \"docker-compose -f docker-compose.yml up -d nginx\"" | sudo tee /etc/cron.d/certbot-renewal
      break
      ;;
    "Self-Signed")
      echo "Generating self-signed certificate..."
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/self-signed/key.pem -out nginx/ssl/self-signed/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=${DOMAIN_NAME}"
      # Update nginx.conf (Self-Signed)
      sed -i "s|listen       80;|listen       443 ssl;|" nginx/nginx.conf
      sed -i "s|server_name  .*;|server_name  ${DOMAIN_NAME};|" nginx/nginx.conf
      sed -i "s|# Redirect HTTP to HTTPS|# Redirect HTTP to HTTPS\n        if (\$scheme = http) {\n            return 301 https://\$server_name\$request_uri;\n        }|" nginx/nginx.conf
      sed -i "/server_name  ${DOMAIN_NAME};/a \        ssl_certificate     /etc/nginx/ssl/self-signed/cert.pem;" nginx/nginx.conf
      sed -i "/ssl_certificate     \/etc\/nginx\/ssl\/self-signed\/cert.pem;/a \        ssl_certificate_key /etc/nginx/ssl/self-signed/key.pem;" nginx/nginx.conf
      # Update docker-compose.yml (Self-Signed)
      sed -i "s|      - \"\${NGINX_PORT}:80\"|      - \"\${NGINX_PORT}:443\"\n      - \"80:80\"|" docker-compose.yml
      sed -i "/- \${PWD}\/log\/nginx.log:\/var\/log\/nginx\/access.log/a \      - \${PWD}/nginx/ssl:/etc/nginx/ssl:ro" docker-compose.yml
      break
      ;;
    *) echo "Invalid choice.";;
  esac
done

# --- Build and Run Docker Compose ---
docker compose build --no-cache
docker compose up 

echo "Setup complete!"
