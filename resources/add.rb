property :name, String, name_property: true
property :source, String
property :cookbook, String, default: 'dapl'
property :variables, Hash, default: {}

action :create do
  name = new_resource.name
  source = new_resource.source || "ldif/#{name}.ldif.erb"
  cookbook = new_resource.cookbook
  variables = new_resource.variables
  file = "#{node.dapl.dir.migrations}/#{name}.ldif"
  complete = "#{node.dapl.dir.migrations}/.#{name}.ldif"

  template file do
    source source
    cookbook cookbook
    variables variables
  end

  execute "ldapadd -w #{node.dapl.plainpw} -D #{node.dapl.rootdn},#{node.dapl.basedn} -f #{file} && touch #{complete}" do
    creates complete
    # notifies :restart, "service[slapd]", :delayed
  end
end
