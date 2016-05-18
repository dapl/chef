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

  raise '[!!!] must set certificate in configuration' unless cert
  raise '[!!!] must set key in configuration' unless priv
  raise '[!!!] must set ca certificate in configuration' unless cacert

  if Dapl.config.ssl.manage
    # if manage is true, load files from cookbook
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
  else
    # if manage is false, assume files are installed in /etc/ssl
    directory Dapl.config.dir.certs do
      owner Dapl.config.system.user
      group Dapl.config.system.group
      mode 0755
    end

    link "#{Dapl.config.dir.certs}/#{cacert}" do
      to "#{Dapl.config.system.certs}/#{cacert}"
    end

    link "#{Dapl.config.dir.certs}/#{cert}" do
      to "#{Dapl.config.system.certs}/#{cert}"
    end

    link "#{Dapl.config.dir.certs}/#{priv}" do
      to "#{Dapl.config.system.private}/#{priv}"
      link_type :hard
    end

    file "#{Dapl.config.dir.certs}/#{priv}" do
      owner Dapl.config.system.user
      group Dapl.config.system.group
      mode 0600
    end
  end

  dapl_config 'set_ssl' do
    variables cert: "#{Dapl.config.dir.certs}/#{cert}",
              key: "#{Dapl.config.dir.certs}/#{priv}",
              cacert: "#{Dapl.config.dir.certs}/#{cacert}",
              verify: verify
  end
end
