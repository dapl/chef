property :name, String, name_property: true
property :source, String
property :cookbook, String, default: 'dapl'

action :create do
  schema = new_resource.name
  source = new_resource.source || "ldif/schema/#{schema}.ldif"
  cookbook = new_resource.cookbook
  file = "#{node.dapl.dir.schema}/#{name}.ldif"

  cookbook_file file do
    source source
    cookbook cookbook
  end

  execute "schema-#{schema}" do
    command "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f #{file}"
    not_if "slapcat -n0 -F /etc/ldap/slapd.d | grep #{schema},cn=schema"
    # notifies :restart, "service[slapd]", :delayed
  end
end
