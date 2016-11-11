module Stormpath
  module Test
    module EnvNamesWarning
      TEST_ENV_VARS = {
        required: {
          STORMPATH_CLIENT_APIKEY_ID: 'The id from your Stormpath API Key',
          STORMPATH_CLIENT_APIKEY_SECRET: 'The secret from your Stormpath API Key'
        },
        deprecated: {
          STORMPATH_SDK_TEST_API_KEY_ID: 'The id from your Stormpath API Key',
          STORMPATH_SDK_TEST_API_KEY_SECRET: 'The secret from your Stormpath API Key'
        }
      }.freeze

      def self.test_missing_deprecated_env_vars
        TEST_ENV_VARS[:deprecated].reject do |var, _|
          ENV[var.to_s]
        end
      end

      def self.test_missing_required_env_vars
        TEST_ENV_VARS[:required].reject do |var, _|
          ENV[var.to_s]
        end
      end

      def self.env_vars_not_set?
        !test_missing_deprecated_env_vars.empty? && !test_missing_required_env_vars.empty?
      end

      def self.check_env_variable_names
        unless Stormpath::Test::EnvNamesWarning.test_missing_required_env_vars.empty?
          warn_message = "\n\n"
          40.times { warn_message << '*' }
          warn_message << 'STORMPATH RUBY SDK'
          52.times { warn_message << '*' }
          warn_message << "\n\n"
          warn_message << TEST_ENV_VARS[:deprecated].map do |var, _|
            "\t#{var} will be deprecated in the next release of the Ruby SDK."
          end.join("\n")
          warn_message << "\n\tPlease update your environment variables to use the new names:\n"
          warn_message << "\n\t\texport STORMPATH_CLIENT_APIKEY_ID=your_api_key_id"
          warn_message << "\n\t\texport STORMPATH_CLIENT_APIKEY_SECRET=your_api_key_secret\n\n"
          110.times { warn_message << '*' }
          warn "#{warn_message}\n\n"
        end

        if Stormpath::Test::EnvNamesWarning.env_vars_not_set?
          set_up_message = "In order to run the specs of the Stormpath SDK you need to setup the following environment variables:\n\t"
          set_up_message << Stormpath::Test::EnvNamesWarning.test_missing_required_env_vars.map do |var, message|
            "#{var} : #{message}"
          end.join("\n\t")
          set_up_message << "\nBe sure to configure these before running the specs again."
          raise set_up_message
        end
      end
    end
  end
end
