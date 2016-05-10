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
    hostname 'ldap02.dapl.com'
    aliases ['ldap02']
  end
  hostsfile_entry '192.168.33.33' do
    hostname 'ldap01.dapl.com'
    aliases ['ldap01']
  end
  # hostsfile_entry '192.168.33.34' do
  #   hostname 'ldap02.dapl.com'
  #   aliases ['ldap02']
  # end
end

node.set.dapl.ssl.cacert = 'cacert.pem'
node.set.dapl.ssl.certfile = 'ldap02.crt'
node.set.dapl.ssl.keyfile = 'ldap02.key'

dapl_server 'secondary' do
  config node.dapl
  primary 'ldap01.dapl.com'
  replication 0
end
