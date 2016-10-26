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

      def test_missing_deprecated_env_vars
        TEST_ENV_VARS[:deprecated].reject do |var, _message|
          ENV[var.to_s]
        end
      end

      def test_missing_required_env_vars
        TEST_ENV_VARS[:required].reject do |var, _message|
          ENV[var.to_s]
        end
      end

      def env_vars_not_set?
        !test_missing_deprecated_env_vars.empty? && !test_missing_required_env_vars.empty?
      end

      def fixture_path
        File.expand_path('../../fixtures/response', __FILE__)
      end

      def fixture(file)
        File.new(fixture_path + '/' + file)
      end
    end
  end
end
