#
# Cookbook Name:: dapl
# Resource: ldif
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#
# dapl_ldif:
# use a template to create an LDIF file and load it
# deletes file when successful

require 'digest/md5'

property :name, String, name_property: true
property :source, String
property :cookbook, String, default: 'dapl'
property :variables, Hash, default: {}

def md5sum(data)
  Digest::MD5.hexdigest(data)
end

action :create do
  name = new_resource.name
  source = new_resource.source || "ldif/#{name}.ldif.erb"
  cookbook = new_resource.cookbook
  variables = new_resource.variables
  file = "/tmp/#{name}-#{$$}-#{md5sum(variables.to_s)}.ldif"

  template file do
    source source
    cookbook cookbook
    variables variables
    action :create
    notifies :delete, "template[#{file}]", :delayed
  end

  # execute "ldapadd -w #{Dapl.config.plainpw} -D #{Dapl.config.rootdn},#{Dapl.config.basedn} -f #{file}" do
  execute "#{Dapl.command(:add, :root)} -f #{file}" do
    # notifies :restart, "service[slapd]", :delayed
  end
end
