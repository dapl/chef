class Dapl
  class << self
    def command(action, user, pass=nil)
      cmd = []
      cmd << "ldap#{action}"
      cmd << '-LLL -o ldif-wrap=no' if action == :search
      if user.to_sym == :admin
        raise 'must set pass for user admin' unless pass
        cmd << "-w #{pass} -D cn=admin,dc=dapl,dc=com"
      elsif user.to_sym == :root
        cmd << '-Y EXTERNAL -Q -H ldapi:///'
      end
      cmd.join(' ')
    end
  end
end
