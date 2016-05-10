# Rakefile for dapl cookbook
# generate SSL certs into databag

COMPANY_NAME = 'Dapl'
SSL_COUNTRY_NAME = 'US'
SSL_STATE_NAME = 'CA'
SSL_LOCALITY_NAME = 'San Francisco'
SSL_ORGANIZATIONAL_UNIT_NAME = 'Operations'
SSL_EMAIL_ADDRESS = 'operations@dapl.com'
ROOT='dapl.com'
HOSTS=%w{ldap01.dapl.com ldap02.dapl.com}
DAYS=3650

namespace :ssl do
  task :create do
    dir = "/tmp/dapl-ssl-#{$$}"
    FileUtils.mkdir_p(dir)

    Dir.chdir(dir)
    puts "files in: #{dir}"

    ssh_config(ROOT)
    # create root CA
    sh "openssl genrsa -out #{ROOT}.key 1024"
    sh "openssl req -config '#{dir}/#{ROOT}.cfg' -new -key #{ROOT}.key -out #{ROOT}.csr"
    sh "openssl x509 -req -days #{DAYS} -in #{ROOT}.csr -set_serial #{Time.now.to_i} -signkey #{ROOT}.key -out #{ROOT}.crt"
    # sh "openssl req -text -noout -verify -in #{ROOT}.crt > #{ROOT}.info"

    HOSTS.each do |host|
      ssh_config(host)
      sh "openssl genrsa -out #{host}.key 1024"
      sh "openssl req -config '#{dir}/#{host}.cfg' -new -key #{host}.key -out #{host}.csr"
      sh "openssl x509 -req -days #{DAYS} -in #{host}.csr -set_serial #{Time.now.to_i} -CA #{ROOT}.crt -CAkey #{ROOT}.key -out #{host}.crt"
      # sh "openssl x509 -inform der -in #{host}.crt -out #{host}.pem"
      # sh "openssl req -text -noout -verify -in #{host}.crt > #{host}.info"
    end
  end
end

def ssh_config(name)
  config = <<-EOF
[ req ]
distinguished_name = req_distinguished_name
prompt = no

[ req_distinguished_name ]
C                      = #{SSL_COUNTRY_NAME}
ST                     = #{SSL_STATE_NAME}
L                      = #{SSL_LOCALITY_NAME}
O                      = #{COMPANY_NAME}
OU                     = #{SSL_ORGANIZATIONAL_UNIT_NAME}
CN                     = #{name}
emailAddress           = #{SSL_EMAIL_ADDRESS}
  EOF
  File.write("#{name}.cfg", config)
end
