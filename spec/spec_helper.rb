# Note: If SimpleCov starts after your application code is already loaded (via require),
# it won't be able to track your files and their coverage! The SimpleCov.start must be
# issued before any of your application code is required!
require 'simplecov'
SimpleCov.start

require 'stormpath-sdk'
require 'pry'
require 'pry-debugger'
require 'webmock/rspec'

WebMock.allow_net_connect!

module Stormpath
  module TestApiKeyHelpers
    def test_api_key_id
      ENV['STORMPATH_TEST_API_KEY_ID']
    end

    def test_api_key_secret
      ENV['STORMPATH_TEST_API_KEY_SECRET']
    end

    def test_api_key
      Stormpath::ApiKey.new test_api_key_id,
        test_api_key_secret
    end

    def test_api_client
      Stormpath::Client.new api_key: test_api_key
    end

    def tests_runnable?
      test_api_key_id and test_api_key_secret
    end
  end

  module TestResourceHelpers
    def generate_resource_name
      "Test#{SecureRandom.uuid}"
    end

    def destroy_all_stormpath_test_resources api_key
      client = Stormpath::Client.new({
        api_key: api_key
      })

      tenant = client.tenant

      directories = tenant.directories

      directories.each do |dir|
        if dir.name.start_with? 'Test'
          accounts = dir.accounts
          accounts.each do |account|
            account.delete
          end
          dir.delete
        end
      end

      applications = tenant.applications

      applications.each do |app|
        app.delete if app.name.start_with? 'Test'
      end
    end
  end
end

RSpec.configure do |c|
  c.include Stormpath::TestApiKeyHelpers
  c.include Stormpath::TestResourceHelpers

  c.before(:all) do
    unless tests_runnable?
      raise <<needs_setup
    In order to run these tests, you need to define the
    STORMPATH_TEST_API_KEY_ID and STORMPATH_TEST_API_KEY_SECRET
needs_setup
    end

    destroy_all_stormpath_test_resources test_api_key
  end

  c.after(:all) do
    destroy_all_stormpath_test_resources test_api_key
  end
end
