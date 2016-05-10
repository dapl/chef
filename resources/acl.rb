#
# Cookbook Name:: dapl
# Resource: acl
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#
# dapl_acl:
# add, update, or delete ACL

property :name, String, name_property: true
property :index, Integer, default: 0
property :what, String
property :who, String, default: '*'
property :list, Array, default: []

action :update do
  vars = {
      index: new_resource.index,
      what: new_resource.what,
      who: new_resource.who,
      list: new_resource.list,
  }
  # TODO: need a way to check for current value
  # cmd = "#{Dapl.command(:search, :root)} -b cn=config olcAccess | grep {#{index}}to #{what} by #{list.map{|e| [e[:who], e[:access]].join(' ')}.join(' by ')}"
  dapl_config name do
    source 'ldif/config/update_acl.ldif.erb'
    variables vars
  end
end
