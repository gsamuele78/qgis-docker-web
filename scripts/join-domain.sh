#!/bin/bash

# Update system
apt update && apt upgrade -y

# Install required packages
apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

# Discover the domain
realm discover pippo.pluto.com

# Join the domain (replace with your domain admin credentials)
echo "YOUR_DOMAIN_ADMIN_PASSWORD" | realm join --user=administrator@pippo.pluto.com pippo.pluto.com -v

# Edit SSSD configuration
cat <<EOF | tee /etc/sssd/sssd.conf
[sssd]
domains = pippo.pluto.com
config_file_version = 2
services = nss, pam

[domain/pippo.pluto.com]
ad_domain = pippo.pluto.com
krb5_realm = PIPPO.PLUTO.COM
realmd_tags = manages-system joined-with-samba
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = True
fallback_homedir = /home/%u
access_provider = ad

# Add the following lines to enable caching:
enumerate = false
cache_timeout = 300
EOF

# Enable SSSD and oddjobd
systemctl enable sssd oddjobd
systemctl restart sssd oddjobd

# (Optional) Set domain user password policy
# chage -M 90 <domain_user> # Set max password age

echo "Domain join completed. You may need to reboot the server."#!/bin/bash

# Update system
apt update && apt upgrade -y

# Install required packages
apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

# Discover the domain
realm discover pippo.pluto.com

# Join the domain (replace with your domain admin credentials)
echo "YOUR_DOMAIN_ADMIN_PASSWORD" | realm join --user=administrator@pippo.pluto.com pippo.pluto.com -v

# Edit SSSD configuration
cat <<EOF | tee /etc/sssd/sssd.conf
[sssd]
domains = pippo.pluto.com
config_file_version = 2
services = nss, pam

[domain/pippo.pluto.com]
ad_domain = pippo.pluto.com
krb5_realm = PIPPO.PLUTO.COM
realmd_tags = manages-system joined-with-samba
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = True
fallback_homedir = /home/%u
access_provider = ad

# Add the following lines to enable caching:
enumerate = false
cache_timeout = 300
EOF

# Enable SSSD and oddjobd
systemctl enable sssd oddjobd
systemctl restart sssd oddjobd

# (Optional) Set domain user password policy
# chage -M 90 <domain_user> # Set max password age

echo "Domain join completed. You may need to reboot the server."
