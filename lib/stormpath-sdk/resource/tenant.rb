module Stormpath

  module Resource

    class Tenant < InstanceResource

      NAME = "name"
      KEY = "key"
      APPLICATIONS = "applications"
      DIRECTORIES = "directories"

      def get_name
        get_property NAME
      end

      def get_key
        get_property KEY
      end

      def create_application application

        href = "/applications"; #TODO: enable auto discovery
        dataStore.create href, application, Application

      end

      def get_applications

        get_resource_property APPLICATIONS, ApplicationList

      end

      def get_directories

        get_resource_property DIRECTORIES, DirectoryList

      end

      def verify_account_email token

        #TODO: enable auto discovery via Tenant resource (should be just /emailVerificationTokens)
        href = "/accounts/emailVerificationTokens/" + token

        tokenHash = Hash.new
        tokenHash.store HREF_PROP_NAME, href

        evToken = dataStore.instantiate EmailVerificationToken, tokenHash

        #execute a POST (should clean this up / make it more obvious)
        dataStore.save evToken, Account
      end

    end
  end
end