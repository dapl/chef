# dapl

Configure LDAP primary and secondary servers, SSL/TLS, and replication

This cookbook is designed primarily to be used to configure LDAP servers
for usage with LDAP+SSH keys. As such, it is primarily concerned with configuring
posix users and accounts, openssh-lpk configuration, TLS, and replication.

It could, in the future, be adapted to support other LDAP-based solutions.

## References

Pages I used for reference implementation of OpenLDAP

https://help.ubuntu.com/lts/serverguide/openldap-server.html
https://www.digitalocean.com/community/tutorials/how-to-encrypt-openldap-connections-using-starttls
http://www.openldap.org/faq/data/cache/185.html
