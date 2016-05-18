#
# Cookbook Name:: dapl
# Resource: ou
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#
# dapl_ou:
# Create organizational unit

property :name, String, name_property: true
property :dn, String
property :base, String #, default: Dapl.config.basedn
property :objectClasses, Array, default: %w{top organizationalUnit}
property :description, String

def vars(r)
  {
      name: r.name,
      dn: r.dn || "ou=#{r.name},#{r.base}",
      ou: r.name.capitalize,
      classes: r.objectClasses,
      description: r.description,
  }
end

action :create do
  vars = vars(new_resource)
  dapl_ldif 'ou_create' do
    variables vars
    not_if "ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b #{Dapl.config.basedn} dn | grep #{vars[:dn]}"
  end
end
