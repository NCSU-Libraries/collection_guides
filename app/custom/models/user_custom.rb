require 'active_support/concern'

module UserCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from UserCustom"
    end

    devise :wolftech_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    def self.create_from_ldap(unity_id, options = {})
      email = "#{unity_id}@ncsu.edu"
      user = User.find_by(email: email)
      if !user
        attributes = attributes_from_ldap(unity_id)
        if attributes
          user = create!(attributes)
        end
      end
      user
    end


    def self.attributes_from_ldap(uid)
      uid.strip!

      map_attributes = lambda do |ldap_entry|
        puts ldap_entry.inspect
        unity_id = ldap_entry.uid[0]
        attributes = {
          email: "#{unity_id}@ncsu.edu",
          display_name: ldap_entry.displayname[0],
          first_name: ldap_entry.givenname[0],
          last_name: ldap_entry.sn[0],
          password: SecureRandom.hex(16)
        }
        return attributes
      end

      # try unity ID first
      uid.gsub!(/\@[A-Za-z0-9]+\.[A-Za-z0-9]+$/,'')
      ldap_entry = NcsuLdap.entry_by_unityid(uid)

      if ldap_entry
        attributes = map_attributes.call(ldap_entry)
      else
        # no results as unityID, try as email
        uid += '@ncsu.edu'
        ldap_entry = NcsuLdap.entry_by_email(uid)
        if ldap_entry
          attributes = map_attributes.call(ldap_entry)
        else
          attributes = nil
        end
      end
      attributes
    end


    def update_from_ldap
      attributes = User.attributes_from_ldap(self.unity_id)
      if attributes
        update_attributes(attributes)
      end
    end

    ### END - Custom methods

  end

end
