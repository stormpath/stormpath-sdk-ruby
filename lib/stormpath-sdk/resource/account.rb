require "stormpath-sdk/resource/instance_resource"
require "stormpath-sdk/resource/directory"
require "stormpath-sdk/resource/tenant"
require "stormpath-sdk/resource/email_verification_token"
require "stormpath-sdk/resource/group_list"
require "stormpath-sdk/resource/status"

module Stormpath

  module Resource

    class Account < InstanceResource

      include Status

      USERNAME = "username"
      EMAIL = "email"
      PASSWORD = "password"
      GIVEN_NAME = "givenName"
      MIDDLE_NAME = "middleName"
      SURNAME = "surname"
      STATUS = "status"
      GROUPS = "groups"
      DIRECTORY = "directory"
      EMAIL_VERIFICATION_TOKENS = "emailVerificationTokens"

      def initialize dataStore, properties

        super dataStore, properties

      end

      def get_username
        get_property USERNAME
      end

      def set_username username
        set_property USERNAME, username
      end

      def get_email
        get_property EMAIL
      end

      def set_email email
        set_property EMAIL, email
      end

      def set_password password
        set_property PASSWORD, password
      end

      def get_given_name
        get_property GIVEN_NAME
      end

      def set_given_name givenName
        set_property GIVEN_NAME, givenName
      end

      def get_middle_name
        get_property MIDDLE_NAME
      end

      def set_middle_name middleName
        set_property MIDDLE_NAME, middleName
      end

      def get_surname
        get_property SURNAME
      end

      def set_surname surname
        set_property SURNAME, surname
      end

      def get_status
        value = get_property STATUS

        if (!value.nil?)
          value = value.upcase
        end

        value
      end

      def set_status status

        if (get_status_hash.has_key? status)
          #set_property STATUS, get_status_hash.fetch status TODO: implement correctly
        end

      end

      def get_groups
        get_resource_property GROUPS, GroupList
      end

      def get_directory
        get_resource_property DIRECTORY, Directory
      end

      def get_email_verification_token
        get_resource_property EMAIL_VERIFICATION_TOKENS, EmailVerificationToken
      end

    end

  end

end
