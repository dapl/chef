default.dapl.tap do |dapl|
  dapl.domain = 'dapl.com'
  dapl.organization = 'dapl'
  dapl.basedn = 'dc=dapl,dc=com'
  dapl.rootdn = 'cn=admin'
  dapl.plainpw = 'fuckyou'
  dapl.rootpw = '{SSHA}qPiMYtdHsah21JJgtP7CvVCoR/JzRCR6'
  dapl.schema = %w{openssh-lpk}
  dapl.users = 'ou=users,dc=dapl,dc=com'
  dapl.groups = 'ou=groups,dc=dapl,dc=com'

  dapl.system.user = 'openldap'
  dapl.system.group = 'openldap'
  dapl.system.certs = '/etc/ssl/certs'
  dapl.system.private = '/etc/ssl/private'
  dapl.system.cacert = 'ca-certificates.crt'
  dapl.dir.base = '/etc/ldap'
  dapl.dir.slapd = '/etc/ldap/slapd.d'
  dapl.dir.migrations = '/etc/ldap/migrations'
  dapl.dir.schema = '/etc/ldap/schema'
  dapl.dir.certs = '/etc/ldap/certs'

  dapl.ssl.tls = true
  dapl.ssl.manage = true
  dapl.ssl.cookbook = 'dapl'
  dapl.ssl.cacert = nil
  dapl.ssl.certfile = nil
  dapl.ssl.keyfile = nil
  dapl.ssl.verify = 'never'

  dapl.preseed_dir = '/var/cache/local/preseeding'

  dapl.nss.base = 'cn=nssproxy,ou=users,dc=dapl,dc=com'
  dapl.nss.pass = 'blarg'
  dapl.nss.ssha = '{SSHA}EiAR459tQ0fzJOxdDE8GXzGHITeURbMz'
  dapl.nss.url = 'ldap://localhost'

  dapl.duser.pass = 'blarg'
  dapl.duser.ssha = '{SSHA}QCiRa8LUt4AZipGcNQgnWcnJJaD1wfXZ'
end
