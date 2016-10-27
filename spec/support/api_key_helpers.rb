module Stormpath
  module Test
    module ApiKeyHelpers
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

      def test_api_key_id
        ENV['STORMPATH_CLIENT_APIKEY_ID'] || ENV['STORMPATH_SDK_TEST_API_KEY_ID']
      end

      def test_api_key_secret
        ENV['STORMPATH_CLIENT_APIKEY_SECRET'] || ENV['STORMPATH_SDK_TEST_API_KEY_SECRET']
      end

      def test_api_key
        Stormpath::ApiKey.new(test_api_key_id, test_api_key_secret)
      end

      def test_api_client
        @test_api_client ||= Stormpath::Client.new(api_key: test_api_key)
      end

      def get_cache_data(href)
        data_store = test_api_client.send :data_store
        data_store.send :cache_for, href
      end

      def fixture_path
        File.expand_path('../../fixtures/response', __FILE__)
      end

      def fixture(file)
        File.new(fixture_path + '/' + file)
      end

      def self.test_missing_deprecated_env_vars
        TEST_ENV_VARS[:deprecated].reject do |var, _message|
          ENV[var.to_s]
        end
      end

      def self.test_missing_required_env_vars
        TEST_ENV_VARS[:required].reject do |var, _message|
          ENV[var.to_s]
        end
      end

      def self.env_vars_not_set?
        !Stormpath::Test::ApiKeyHelpers.test_missing_deprecated_env_vars.empty? &&
          !Stormpath::Test::ApiKeyHelpers.test_missing_required_env_vars.empty?
      end

      def self.check_env_variable_names
        unless TEST_ENV_VARS[:required].reject { |var, _message| ENV[var.to_s] }.empty?
          warn_message = "\n\n"
          40.times { warn_message << '*' }
          warn_message << 'STORMPATH RUBY SDK'
          52.times { warn_message << '*' }
          warn_message << "\n\n"
          warn_message << Stormpath::Test::ApiKeyHelpers::TEST_ENV_VARS[:deprecated].map do |var, _|
            "\t#{var} will be deprecated in the next release of the Ruby SDK."
          end.join("\n")
          warn_message << "\n\tPlease update your environment variables to use the new names:\n"
          warn_message << "\n\t\texport STORMPATH_CLIENT_APIKEY_ID=your_api_key_id"
          warn_message << "\n\t\texport STORMPATH_CLIENT_APIKEY_SECRET=your_api_key_secret\n\n"
          110.times { warn_message << '*' }
          warn "#{warn_message}\n\n"
        end

        if Stormpath::Test::ApiKeyHelpers.env_vars_not_set?
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
