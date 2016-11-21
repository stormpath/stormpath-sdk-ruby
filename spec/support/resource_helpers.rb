module Stormpath
  module Test
    module ResourceHelpers
      def account_attrs(opts = {})
        opts.tap do |o|
          if !opts[:email].blank? && opts[:email]
            if opts[:email].include?('@')
              raise ArgumentError, "Invalid email format. Please send the email without the domain. For example, 'anakin.skywalker', instead of 'anakin.skywalker@darkside.com'"
            end
            o[:email] = "#{opts[:email]}#{default_domain}"
          else
            o[:email] = "ruby#{random_number}#{default_domain}"
          end
          o[:username]   = (!opts[:username].blank? && opts[:username]) || "ruby#{random_number}"
          o[:password]   = (!opts[:password].blank? && opts[:password]) || 'P@$$w0rd'
          o[:surname]    = (!opts[:surname].blank? && opts[:surname]) || 'surname'
          o[:given_name] = (!opts[:given_name].blank? && opts[:given_name]) || 'givenname'
          o[:middle_name] = (!opts[:middle_name].blank? && opts[:middle_name]) || 'middle_name'
          o[:status] = (!opts[:status].blank? && opts[:status]) || 'ENABLED'
        end
      end

      def default_domain
        '@testmail.stormpath.com'
      end

      def application_attrs(opts = {})
        opts.tap do |o|
          o[:name]          = (!opts[:name].blank? && opts[:name]) || "ruby-app-#{random_number}"
          o[:description]   = (!opts[:description].blank? && opts[:description]) || 'ruby desc'
        end
      end

      def directory_attrs(opts = {})
        opts.tap do |o|
          o[:name]          = (!opts[:name].blank? && opts[:name]) || "ruby-dir-#{random_number}"
          o[:description]   = (!opts[:description].blank? && opts[:description]) || 'ruby desc'
        end
      end

      def organization_attrs(opts = {})
        opts.tap do |o|
          o[:name]      = (!opts[:name].blank? && opts[:name]) || "ruby-org-#{random_number}"
          o[:name_key]  = (!opts[:name_key].blank? && opts[:name_key]) || "ruby-org-#{random_number}"
        end
      end

      def group_attrs(opts = {})
        opts.tap do |o|
          o[:name]      = (!opts[:name].blank? && opts[:name]) || "ruby-group-#{random_number}"
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

      def random_number
        SecureRandom.hex(15)
      end
    end
  end
end
