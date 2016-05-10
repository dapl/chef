#
# Cookbook Name:: dapl
# Recipe:: default
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#

if node['automation']
  # for testing, set the host name correctly
  hostsfile_entry '127.0.1.1' do
    hostname 'ldap01.dapl.com'
    aliases ['ldap01']
  end
  # hostsfile_entry '192.168.33.33' do
  #   hostname 'ldap01.dapl.com'
  #   aliases ['ldap01']
  # end
  hostsfile_entry '192.168.33.34' do
    hostname 'ldap02.dapl.com'
    aliases ['ldap02']
  end
end

node.set.dapl.ssl.cacert = 'cacert.pem'
node.set.dapl.ssl.certfile = 'ldap01.crt'
node.set.dapl.ssl.keyfile = 'ldap01.key'

# cookbook_file '/root/generate_certificate.sh' do
#   source 'generate_certificate.sh'
#   mode 0755
# end

dapl_server 'primary' do
  config node.dapl
end
