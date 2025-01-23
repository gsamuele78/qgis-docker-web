#!/bin/bash

# DuckDNS API credentials (replace with your actual token)
DUCKDNS_TOKEN="YOUR_DUCKDNS_TOKEN"

if [ "$CERTBOT_VALIDATION" = "" ]; then
  echo "Error: CERTBOT_VALIDATION environment variable not set."
  exit 1
fi

if [ "$CERTBOT_DOMAIN" = "" ]; then
  echo "Error: CERTBOT_DOMAIN environment variable not set."
  exit 1
fi

# Extract subdomain from CERTBOT_DOMAIN if needed (for subdomains)
SUBDOMAIN=$(echo "$CERTBOT_DOMAIN" | sed -e "s/^\*\.//" -e "s/\.${DUCKDNS_DOMAIN}$//")

if [ "$1" = "renew" ]; then
  # Update DuckDNS TXT record for _acme-challenge
  RECORD_ID=$(curl -s -X GET "https://www.duckdns.org/update?domains=${SUBDOMAIN}.${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&txt=${CERTBOT_VALIDATION}")

  if [[ "$RECORD_ID" == "OK" ]]; then
    echo "DuckDNS TXT record updated successfully."
  else
    echo "Error updating DuckDNS TXT record. Response: $RECORD_ID"
    exit 1
  fi

  # Wait for DNS propagation (adjust sleep time if needed)
  sleep 60
elif [ "$1" = "cleanup" ]; then
  # Clear DuckDNS TXT record after validation
  RECORD_ID=$(curl -s -X GET "https://www.duckdns.org/update?domains=${SUBDOMAIN}.${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&clear=true")

  if [[ "$RECORD_ID" == "OK" ]]; then
    echo "DuckDNS TXT record cleared successfully."
  else
    echo "Error clearing DuckDNS TXT record. Response: $RECORD_ID"
    exit 1
  fi
else
  echo "Invalid argument: $1"
  exit 1
fi
