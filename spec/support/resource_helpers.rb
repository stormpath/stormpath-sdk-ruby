module Stormpath
  module Test
    module ResourceHelpers
      def account_attrs(opts = {})
        opts.tap do |o|
          if !opts[:email].blank? && opts[:email]
            if opts[:email].include?('@')
              raise(
                ArgumentError,
                'Invalid email format. Please send the email without the domain. For example,' \
                " 'anakin.skywalker', instead of 'anakin.skywalker@darkside.com'"
              )
            end
            o[:email] = "#{opts[:email]}#{default_domain}"
          else
            o[:email] = "ruby#{random_number}#{default_domain}"
          end
          o[:username]   = (!opts[:username].blank? && opts[:username]) || "ruby#{random_number}"
          o[:password]   = (!opts[:password].blank? && opts[:password]) || 'P@$$w0rd'
          o[:surname]    = (!opts[:surname].blank? && opts[:surname]) || 'ruby'
          o[:given_name] = (!opts[:given_name].blank? && opts[:given_name]) || 'ruby'
          o[:middle_name] = (!opts[:middle_name].blank? && opts[:middle_name]) || 'ruby'
          o[:status] = (!opts[:status].blank? && opts[:status]) || 'ENABLED'
        end
      end

      def default_domain
        '@testmail.stormpath.com'
      end

      def test_host
        Stormpath::DataStore::DEFAULT_SERVER_HOST
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
          o[:name]        = (!opts[:name].blank? && opts[:name]) || "ruby-org-#{random_number}"
          o[:description] = (!opts[:description].blank? && opts[:description]) || "ruby-org-#{random_number}"
          o[:name_key]    = (!opts[:name_key].blank? && opts[:name_key]) || "ruby-org-#{random_number}"
        end
      end

      def group_attrs(opts = {})
        opts.tap do |o|
          o[:name]        = (!opts[:name].blank? && opts[:name]) || "ruby-group-#{random_number}"
          o[:description] = (!opts[:description].blank? && opts[:description]) || "ruby-group-desc-#{random_number}"
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

      def ldap_agent_attrs
        {
          config: {
            directory_host: 'ldap.local',
            directory_port: '636',
            ssl_required: true,
            agent_user_dn: 'tom@stormpath.com',
            agent_user_dn_password: 'StormpathRulez',
            base_dn: 'dc=example,dc=com',
            poll_interval: 60,
            # referral_mode: 'follow',      | attributes used for creating ad directories
            # ignore_referral_issues: true, | -------------------||----------------------
            account_config: {
              dn_suffix: 'ou=employees',
              object_class: 'person',
              object_filter: '(cn=finance)',
              email_rdn: 'email',
              given_name_rdn: 'givenName',
              middle_name_rdn: 'middleName',
              surname_rdn: 'sn',
              username_rdn: 'uid',
              password_rdn: 'userPassword'
            },
            group_config: {
              dn_suffix: 'ou=groups',
              object_class: 'groupOfUniqueNames',
              object_filter: '(ou=*-group)',
              name_rdn: 'cn',
              description_rdn: 'description',
              members_rdn: 'uniqueMember'
            }
          }
        }
      end

      def camelize_keys(hash)
        hash.transform_keys { |key| key.to_s.camelize(:lower).to_s }
      end

      def random_number
        SecureRandom.hex(15)
      end
    end
  end
end
