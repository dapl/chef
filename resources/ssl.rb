#
# Cookbook Name:: dapl
# Resource: ssl
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#
# dapl_ssl:
# configure ldap server for SSL/TLS

property :name, String, name_property: true

action :create do
  cert = node.dapl.ssl.certfile
  priv = node.dapl.ssl.keyfile
  cacert = node.dapl.ssl.cacert
  verify = node.dapl.ssl.verify || 'never'

  if node.dapl.ssl.manage
    remote_directory node.dapl.dir.certs do
      source 'ssl'
      owner node.dapl.system.user
      group node.dapl.system.group
      mode 0755
    end

    file "#{node.dapl.dir.certs}/#{node.dapl.ssl.keyfile}" do
      owner node.dapl.system.user
      group node.dapl.system.group
      mode 0600
    end

    # node.set.ssl.certs_dir = dir
    # node.set.ssl.keys_dir = dir
    # node.set.ssl.group = node.dapl.system.group
    #
    # directory dir do
    #   owner node.dapl.system.user
    #   group node.dapl.system.group
    #   mode 0700
    # end
    #
    # databag = "ssl"
    # data_bag(databag).each do |item|
    #   ssl = data_bag_item(databag, item)
    #   cert_domain = ssl['id'].gsub('_', '.')
    #   install_cert(cert_domain, ssl['cert']) if ssl['cert']
    #
    #   install_cert(cert_domain, ssl['ca'], :ca => true) if ssl['ca']
    #
    #   chain_certs = ssl['chain']
    #   if chain_certs
    #     combined_chain_certs = chain_certs.join("\n")
    #     install_cert(cert_domain, combined_chain_certs, :chain => true)
    #   end
    #
    #   if key = ssl['key']
    #     key_file = "#{cert_domain}.key"
    #     file "#{::File.join node['ssl']['keys_dir'], key_file}" do
    #       owner 'root'
    #       group "#{node['ssl']['group']}"
    #       mode '0640'
    #       content key
    #     end
    #   end
    #
    #   # this is needed by nginx
    #   if chain_certs
    #     combined_certs_file = "#{cert_domain}.combined.crt"
    #     template "#{::File.join node['ssl']['certs_dir'], combined_certs_file}" do
    #       cookbook "ssl"
    #       source "combined_certs.erb"
    #       owner 'root'
    #       group 'root'
    #       mode '0644'
    #       variables :chain_certs => chain_certs,
    #                 :domain_cert => ssl['cert']
    #     end
    #   end
    # end

    # cookbook_file "#{node.dapl.system.certs}/#{cert}" do
    #   source "ssl/#{cert}"
    #   owner 'root'
    #   group 'root'
    #   mode 0644
    #   cookbook node.dapl.ssl.cookbook
    # end
    #
    # cookbook_file "#{node.dapl.system.private}/#{priv}" do
    #   source "ssl/#{priv}"
    #   owner 'root'
    #   group 'root'
    #   mode 0600
    #   cookbook node.dapl.ssl.cookbook
    # end
  end

  # directory node.dapl.dir.certs do
  #   owner node.dapl.system.user
  #   group node.dapl.system.group
  #   mode 0700
  # end

  # link "#{node.dapl.dir.certs}/cacert.crt" do
  #   to "#{node.dapl.system.certs}/#{node.dapl.system.cacert}"
  # end
  #
  # link "#{node.dapl.dir.certs}/#{cert}" do
  #   to "#{node.dapl.system.certs}/#{cert}"
  # end
  #
  # link "#{node.dapl.dir.certs}/#{priv}" do
  #   to "#{node.dapl.system.private}/#{priv}"
  #   link_type :hard
  # end

  # file "#{node.dapl.dir.certs}/#{priv}" do
  #   owner node.dapl.system.user
  #   group node.dapl.system.group
  #   mode 0600
  # end

  dapl_config 'set_ssl' do
    variables cert: "#{node.dapl.dir.certs}/#{cert}",
              key: "#{node.dapl.dir.certs}/#{priv}",
              cacert: "#{node.dapl.dir.certs}/#{cacert}",
              verify: verify
  end
end
