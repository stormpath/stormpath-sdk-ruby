# Note: If SimpleCov starts after your application code is already loaded (via require),
# it won't be able to track your files and their coverage! The SimpleCov.start must be
# issued before any of your application code is required!
require 'simplecov'
SimpleCov.start

require 'stormpath-sdk'
require 'pry'
require 'webmock/rspec'
WebMock.allow_net_connect!

def destroy_all_stormpath_test_resources api_key
  client = Stormpath::Client.new({
    api_key: api_key
  })

  tenant = client.current_tenant

  directories = tenant.directories

  directories.each do |dir|
    dir.delete if dir.name.start_with? 'TestDirectory'
  end

  applications = tenant.applications

  applications.each do |app|
    app.delete if app.name.start_with? 'TestApplication'
  end
end

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

    def tests_runnable?
      test_api_key_id and test_api_key_secret
    end
  end
end

RSpec.configure do |c|
  c.include Stormpath::TestApiKeyHelpers
  c.before(:all) do
    unless tests_runnable?
      raise <<needs_setup
    In order to run these tests, you need to define the
    STORMPATH_TEST_API_KEY_ID and STORMPATH_TEST_API_KEY_SECRET
needs_setup
    end
  end
end
