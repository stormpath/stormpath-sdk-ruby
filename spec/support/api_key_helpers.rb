module Stormpath
  module Test
    module ApiKeyHelpers
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
        data_store.cache_manager.send :cache_for, href
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
