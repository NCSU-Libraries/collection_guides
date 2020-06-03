require 'net/ldap'

class NcsuLdap

  @@ldap = Net::LDAP.new  host: "ldap.ncsu.edu", # your LDAP host name or IP goes here,
                          port: 636, # your LDAP host port goes here,
                          encryption: :simple_tls,
                          base: "ou=people,dc=ncsu,dc=edu", # the base of your AD tree goes here,
                          cert_store: '/etc/pki/tls/certs/'

  def self.entry_by_unityid(unityid)
    filter = Net::LDAP::Filter.eq('uid', unityid)

    if @@ldap.bind
      entries = @@ldap.search(filter: filter)
      entries.first # there should only ever be one entry for each unityid
    else
      nil # TODO: maybe should raise if can't bind?
    end
  end


  def self.entry_by_email(email)
    filter = Net::LDAP::Filter.eq('mail', email)

    if @@ldap.bind
      entries = @@ldap.search(filter: filter)
      entries.first # there should only ever be one entry for each unityid
    else
      nil # TODO: maybe should raise if can't bind?
    end
  end

end
