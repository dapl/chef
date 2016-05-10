require 'spec_helper'

describe 'dapl::secondary' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  context '#hostname' do
    describe host('ldap02') do
      its(:ipaddress) { should eq '127.0.1.1' }
    end

    describe host('ldap02.dapl.com') do
      its(:ipaddress) { should eq '127.0.1.1' }
    end
  end

  context '#service' do
    describe service('slapd') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context '#cn=config' do
    describe command("sudo ldapsearch -Y EXTERNAL -LLL -Q -H ldapi:/// -b cn=config") do
      its(:exit_status) { should eq 0 }
    end
  end

  context '#search' do
    describe command("ldapsearch -D cn=admin,dc=dapl,dc=com -w fuckyou -b dc=dapl,dc=com -LLL") do
      its(:exit_status) { should eq 0 }
    end
  end

  context '#search-with-ssl' do
    describe command("ldapsearch -D cn=admin,dc=dapl,dc=com -w fuckyou -b dc=dapl,dc=com -LLL -ZZ") do
      its(:exit_status) { should eq 0 }
    end
  end

  context '#search-with-ssl-primary' do
    describe command("ldapsearch -h ldap01.dapl.com -D cn=admin,dc=dapl,dc=com -w fuckyou -b dc=dapl,dc=com -LLL -ZZ") do
      its(:exit_status) { should eq 0 }
    end
  end

end
