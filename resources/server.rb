#
# Cookbook Name:: dapl
# Resource: server
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#
# dapl_server:
# Setup an OpenLDAP server
require 'ostruct'

property :server_type, String, name_property: true
property :config, Hash, default: {}
property :primary, String
property :replication, Integer

def get_props(r)
  basedn = basedn(r.domain)
  {
      type: r.server_type || 'master',
      domain: r.domain,
      organization: r.organization,
      basedn: r.basedn || basedn,
      rootdn: r.rootdn,
      password: r.password,
      ssha: r.ssha,
      users: r.users || "ou=users,#{basedn}",
      groups: r.groups || "ou=groups,#{basedn}"
  }
end

def basedn(d)
  "dc=#{d.split('.').join('dc=')}"
end

action :create do
  supported = %w{debian}
  unless supported.include?(node.platform_family)
    raise "[!!!] unsupported platform family: #{node.platform_family}"
  end

  is_primary = false
  is_secondary = false

  # props = get_props(new_resource)
  primaries = %w{master primary leader}
  secondaries = %w{slave secondary follower}

  unless (primaries+secondaries).include?(server_type)
    raise "[!!!] server_type must be one of: #{primaries + secondaries}"
  end

  if primaries.include?(server_type)
    node.set.dapl.is_primary = is_primary = true
  elsif secondaries.include?(server_type)
    node.set.dapl.is_secondary = is_secondary = true
    raise "[!!!] must specify 'primary' server" unless primary
    raise "[!!!] must specify 'replication' id" unless replication
  end

  include_recipe 'apt::default'
  include_recipe 'apparmor::default'

  template "#{Dapl.config.preseed_dir}/slapd.seed" do
    source 'slapd.seed.erb'
    cookbook 'dapl'
    owner 'root'
    group 'root'
  end

  package 'slapd' do
    action :install
  end

  package 'ldap-utils' do
    action :install
  end

  template '/etc/ldap/ldap.conf' do
    source 'ldap.conf.erb'
    cookbook 'dapl'
    mode 0644
  end

  execute "slaptest -F #{Dapl.config.dir.slapd}"

  service 'slapd' do
    action [:enable, :start]
  end

  directory Dapl.config.dir.migrations do
    owner Dapl.config.system.user
    group Dapl.config.system.group
    mode 0700
  end

  Dapl.config.schema.each do |schema|
    dapl_schema schema
  end

  directory '/var/lib/ldap/accesslog' do
    owner Dapl.config.system.user
    group Dapl.config.system.group
  end

  execute 'cp /var/lib/ldap/DB_CONFIG /var/lib/ldap/accesslog' do
    creates '/var/lib/ldap/accesslog/DB_CONFIG'
    # notifies :reload, 'service[apparmor]'
  end

  dapl_config 'set_config' do
    # notifies :reload, 'service[slapd]', :delayed
  end

  dapl_config 'set_debug' do
    # notifies :reload, 'service[slapd]', :delayed
  end

  dapl_acl 'local_root' do
    index 2
    what '*'
    list [
             {who: 'dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"', access: 'manage'},
             {who: 'dn.exact="cn=admin,dc=dapl,dc=com"', access: 'write'},
             {who: 'dn.exact="cn=nssproxy,ou=users,dc=dapl,dc=com"', access: 'read'},
             {who: '*', access: 'read'}
         ]
    action :update
    # notifies :reload, 'service[slapd]', :delayed
  end

  dapl_ssl 'dapl.com' do
    # notifies :reload, 'service[slapd]', :delayed
  end

  if is_primary
    dapl_ou 'users' do
      description 'Central location for UNIX users'
    end

    dapl_ou 'groups' do
      description 'Central location for UNIX groups'
    end

    dapl_user 'nssproxy' do
      password Dapl.config.nss.pass
      ssha Dapl.config.nss.ssha
      comment 'Network Service Switch Proxy User'
      gid 801
      uid 801
      home '/home/nssproxy'
      shell '/bin/false'
      system true
    end

    dapl_user 'duser' do
      password Dapl.config.duser.pass
      ssha Dapl.config.duser.ssha
      comment 'Default User'
      first 'Default'
      last 'User'
      uid 9999
      gid 9999
      home '/home/duser'
      shell '/bin/false'
      sshkeys [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDARPmYMc+UhfipYTSN4qbEoGpCRxtnX0FuIe9OrP9OjIEuQlrkQ+Ve4ZdREJIPYb5dNb9lZzfX387k5usS51g+/VRdKvCy5kalqmth1EHQFjW6K9E811CCGPrdz7HvYl1j8KK8YLQafxDhgZcOIJre5Wk21C+/SeEON/9Xvt7GsaWdjkfzDCImMW5YYvmDQuTHYnhWL+qM7sQ8eWFR2OTREP+RF4b5YP3hzhpIQOsjnwylRa76GjdG87SmdZpYA5bPt3biKJl6DBE4qSQJMc7XwLbF+Ifid1FLxEX6/8aqlcizE7LcQcPdT5rvYpRkwSwJjZU9bIVdDNuDxvHnZRZH9pfdEzHxqgCiLCd/hbkQPNsD+HohQjDcJ6FEdEgh5lXw288HIBWm2L8MUEqw9OqWKU0mbQbJiFV6v4LhSTxB3PuMH8EbUC98nIQYMwKbR5qmRNdkyqvq5uG6cIGbMStxEs0o0rAyDAIDCmjy0JShX1FgdZtWn6K2jYkGU3BY4VgpNhptiz3XbkVPpvPpgJnQeta7Z519a/RyZmhZO8mkelgGgodHgENd06dZtdsIUvMx+PC3qrtok3bl/OhrLQKsJewFWou9fwnH13AjIlItYhbVugMLnYckAhTMW4rlENQ3kZE0Jhdp5CSbzy9XlNy4QbycGDivWvU2sDyY8/gn9Q== shawn@genma",
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDZcRuMnS/80Ohj59H7E3EOCR8J7pTjCcA/W60ZrZ6Ql3iG7kG+tgZhwdrRAfaKWysIWFyZfL4s+xq38NQQXuzPR2+eF9rWpTkPP47W1VpBsOFpLCzhJ72ZGluR3mbfTLQ2gShSB9bfWoShdXbjxMwX4kSL0haZUalBMibxdPSG+t2STkGQZb5Ocg6wWu24p7+r+JnTyMtDnBATE8ZNWlumxNfwdhPIo8/5wwr7sj81R4lu3MgxEAfFWghSECfzkDvsCyTBzmkSpdymZf1fNN6iMxk5EhZMzfC/ItIC8ciL4p8gZxrHFZvtPrOZ8wBAaIMu1IGZCfmc575ggfNVYpHWERk2HlAoUpCpf7iRPiHgeoclCJnn8iJpspGwv7k+YUEpIK6SVfIn5Wm3b3u3jO4wDpKzav+EnIKGXnsoNMi60JNt/iPHST9El7xFcEte1gTWHSXuwIbwan6nRKhdLXuo22ZMcbSEluv5tz08iAlsNT5WU4PsyW17y8xqz+Dg6A2D7wAfBwCG2zM2g/HItui/cafrqKeAfE3pDHJladFNVgtK3Pt4OmTy1k9j7Le6B48XwF7ZZzwCXZ98yyERLRMy1cg1aCNCJVB2ZR1/zYC3jRUC1VjcdAJ0N8kubcpon5xae3FVLt61HfZvM3OihJxgHxZdGR8XHmDuGWssbXffw== scatanzarite@snsfm-scatan"
              ]
    end
  end

  if is_primary
    dapl_config 'set_repl_provider' do
      ldap_action 'add'
      variables rootdn: "#{Dapl.config.rootdn},#{Dapl.config.basedn}"
      # notifies :reload, 'service[slapd]', :delayed
    end
  else
    dapl_config 'set_repl_consumer' do
      ldap_action 'add'
      variables rootdn: "#{Dapl.config.rootdn},#{Dapl.config.basedn}",
                password: Dapl.config.plainpw,
                basedn: Dapl.config.basedn,
                ssl: Dapl.config.ssl.tls,
                rid: replication,
                primary: primary
    end
  end
end
