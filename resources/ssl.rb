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
  cert = Dapl.config.ssl.certfile
  priv = Dapl.config.ssl.keyfile
  cacert = Dapl.config.ssl.cacert
  verify = Dapl.config.ssl.verify || 'never'

  if Dapl.config.ssl.manage
    remote_directory Dapl.config.dir.certs do
      source 'ssl'
      owner Dapl.config.system.user
      group Dapl.config.system.group
      mode 0755
    end

    file "#{Dapl.config.dir.certs}/#{Dapl.config.ssl.keyfile}" do
      owner Dapl.config.system.user
      group Dapl.config.system.group
      mode 0600
    end

    # node.set.ssl.certs_dir = dir
    # node.set.ssl.keys_dir = dir
    # node.set.ssl.group = Dapl.config.system.group
    #
    # directory dir do
    #   owner Dapl.config.system.user
    #   group Dapl.config.system.group
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

    # cookbook_file "#{Dapl.config.system.certs}/#{cert}" do
    #   source "ssl/#{cert}"
    #   owner 'root'
    #   group 'root'
    #   mode 0644
    #   cookbook Dapl.config.ssl.cookbook
    # end
    #
    # cookbook_file "#{Dapl.config.system.private}/#{priv}" do
    #   source "ssl/#{priv}"
    #   owner 'root'
    #   group 'root'
    #   mode 0600
    #   cookbook Dapl.config.ssl.cookbook
    # end
  end

  # directory Dapl.config.dir.certs do
  #   owner Dapl.config.system.user
  #   group Dapl.config.system.group
  #   mode 0700
  # end

  # link "#{Dapl.config.dir.certs}/cacert.crt" do
  #   to "#{Dapl.config.system.certs}/#{Dapl.config.system.cacert}"
  # end
  #
  # link "#{Dapl.config.dir.certs}/#{cert}" do
  #   to "#{Dapl.config.system.certs}/#{cert}"
  # end
  #
  # link "#{Dapl.config.dir.certs}/#{priv}" do
  #   to "#{Dapl.config.system.private}/#{priv}"
  #   link_type :hard
  # end

  # file "#{Dapl.config.dir.certs}/#{priv}" do
  #   owner Dapl.config.system.user
  #   group Dapl.config.system.group
  #   mode 0600
  # end

  dapl_config 'set_ssl' do
    variables cert: "#{Dapl.config.dir.certs}/#{cert}",
              key: "#{Dapl.config.dir.certs}/#{priv}",
              cacert: "#{Dapl.config.dir.certs}/#{cacert}",
              verify: verify
  end
end
