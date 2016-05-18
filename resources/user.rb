#
# Cookbook Name:: dapl
# Resource: user
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#
# dapl_user:
# Setup a user in the unix users organizational unit
require 'base64'

property :username, String, name_property: true
property :comment, String
property :ou, String
# property :force, TrueClass, FalseClass # see description
property :gid, [String, Integer]
property :home, String
# property :iterations, Integer
# property :manage_home, TrueClass, FalseClass
# property :non_unique, TrueClass, FalseClass
# property :notifies, # see description
property :password, String
property :ssha, String
# property :provider, Chef::Provider::User
# property :salt, String
property :shell, String, default: '/bin/bash'
# property :supports, Hash
# property :subscribes, # see description
property :system, [TrueClass, FalseClass]
property :uid, [String, Integer]
# property :username, String # defaults to 'name' if not specified
property :sshkeys, Array, default: []
property :first, String
property :last, String
property :action, Symbol # defaults to :create if not specified

def vars(r)
  {
      username: r.username,
      ou: r.ou||Dapl.config.users,
      comment: r.comment,
      ssha: r.ssha,
      shell: r.shell,
      uid: r.uid,
      gid: r.gid,
      home: r.home || "/home/#{r.username}",
      system: r.system,
      keys: r.sshkeys.map{|e| Base64.encode64(e).split("\n").join},
      first: r.first,
      last: r.last,
  }
end

action :create do
  vars = vars(new_resource)
  dapl_ldif 'user_create' do
    variables vars
    not_if "ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b #{Dapl.config.basedn} dn | grep cn=#{vars[:username]},#{vars[:ou]}"
  end
end
