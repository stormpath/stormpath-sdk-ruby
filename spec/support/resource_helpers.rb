module Stormpath
  module Test
    module ResourceHelpers
      def build_account(opts = {})
        opts.tap do |o|
          o[:surname]    = (!opts[:surname].blank? && opts[:surname]) || 'surname'
          o[:given_name] = (!opts[:given_name].blank? && opts[:given_name]) || 'givenname'
          o[:username]   = (!opts[:username].blank? && opts[:username]) || random_user_name
          o[:password]   = (!opts[:password].blank? && opts[:password]) || 'P@$$w0rd'
          o[:email]      = (!opts[:email].blank? && opts[:email]) || random_email
        end
      end

      def enable_email_verification(directory)
        directory.account_creation_policy.verification_email_status = 'ENABLED'
        directory.account_creation_policy.verification_success_email_status = 'ENABLED'
        directory.account_creation_policy.welcome_email_status = 'ENABLED'
        directory.account_creation_policy.save
      end

      def map_account_store(app, store, index, default_account_store, default_group_store)
        test_api_client.account_store_mappings.create(
          application: app,
          account_store: store,
          list_index: index,
          is_default_account_store: default_account_store,
          is_default_group_store: default_group_store
        )
      end

      def map_organization_store(account_store, organization, default_account_store = false)
        test_api_client.organization_account_store_mappings.create(
          account_store: { href: account_store.href },
          organization: { href: organization.href },
          is_default_account_store: default_account_store
        )
      end
    end
  end
end
