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
        data_store.create href, application, Application

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

        token_hash = Hash.new
        token_hash.store HREF_PROP_NAME, href

        ev_token = data_store.instantiate EmailVerificationToken, token_hash

        #execute a POST (should clean this up / make it more obvious)
        data_store.save ev_token, Account
      end

    end
  end
end