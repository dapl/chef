#!/bin/bash

# https://help.ubuntu.com/lts/serverguide/openldap-server.html#openldap-tls

name=$1
domain=$2
dir="/etc/ldap/certs"

if [ -z "$name" -o -z "$domain" ]; then
  echo "usage: $0 <name> <domain>"
fi

sudo apt install gnutls-bin ssl-cert

certtool --generate-privkey > $dir/cakey.pem

cat <<EOF > $dir/ca.info
cn = Example Company
ca
cert_signing_key
EOF

sudo certtool --generate-self-signed --load-privkey $dir/cakey.pem --template $dir/ca.info --outfile $dir/cacert.pem
sudo certtool --generate-privkey --bits 1024 --outfile $dir/${name}_slapd_key.pem

cat <<EOF > $dir/${name}.info
organization = Example Company
cn = ${name}.${domain}
tls_www_server
encryption_key
signing_key
expiration_days = 3650
EOF

sudo certtool --generate-certificate --load-privkey $dir/${name}_slapd_key.pem --load-ca-certificate $dir/cacert.pem --load-ca-privkey $dir/cakey.pem --template $dir/${name}.info --outfile $dir/${name}_slapd_cert.pem

cat <<EOF > /tmp/ssl.ldif
dn: cn=config
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: $dir/cacert.pem
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: $dir/${name}_slapd_cert.pem
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: $dir/${name}_slapd_key.pem
EOF

sudo adduser openldap ssl-cert
sudo chgrp ssl-cert $dir/${name}_slapd_key.pem
sudo chmod g+r $dir/${name}_slapd_key.pem
sudo chmod o-r $dir/${name}_slapd_key.pem

sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/ssl.ldif

sudo service slapd restart
