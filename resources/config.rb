property :name, String, name_property: true
property :variables, Hash, default: {}
property :source, String
property :cookbook, String, default: 'dapl'
property :ldap_action, String, default: 'modify'

action :create do
  name = new_resource.name
  source = new_resource.source || "ldif/config/#{name}.ldif.erb"
  cookbook = new_resource.cookbook
  file = "#{node.dapl.dir.migrations}/#{name}.ldif"
  complete = "#{node.dapl.dir.migrations}/.#{name}.ldif"
  vars = new_resource.variables

  template file do
    source source
    cookbook cookbook
    variables vars
  end

  execute "ldap#{ldap_action} -Q -Y EXTERNAL -H ldapi:/// -D cn=config -f #{file} && touch #{complete}" do
    creates complete
    # notifies :restart, "service[slapd]", :delayed
  end
end
