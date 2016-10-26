module Stormpath
  module Test
    module EnvNamesWarning
      def check_env_variable_names
        unless test_missing_required_env_vars.empty?
          warn_message = "\n\n"
          30.times { warn_message << '*' }
          warn_message << 'STORMPATH RUBY SDK'
          42.times { warn_message << '*' }
          warn_message << "\n\n"
          warn_message << Stormpath::Test::ApiKeyHelpers::TEST_ENV_VARS[:deprecated].map do |var, message|
            "#{var} will be deprecated in the next release of the Ruby SDK."
          end.join("\n")
          warn_message << "\nPlease update your environment variables to use the new names:\n"
          warn_message << "\n\texport STORMPATH_CLIENT_APIKEY_ID=your_api_key_id"
          warn_message << "\n\texport STORMPATH_CLIENT_APIKEY_SECRET=your_api_key_secret\n"
          90.times { warn_message << '*' }
          warn warn_message
        end

        if env_vars_not_set?
          set_up_message = "In order to run the specs of the Stormpath SDK you need to setup the following environment variables:\n\t"
          set_up_message << test_missing_required_env_vars.map do |var, message|
            "#{var} : #{message}"
          end.join("\n\t")
          set_up_message << "\nBe sure to configure these before running the specs again."
          raise set_up_message
        end
      end
    end
  end
end
