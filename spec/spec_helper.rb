# Note: If SimpleCov starts after your application code is already loaded (via require),
# it won't be able to track your files and their coverage! The SimpleCov.start must be
# issued before any of your application code is required!
require 'simplecov'
SimpleCov.start

require 'stormpath-sdk'
require 'pry'
require 'pry-debugger'
require 'webmock/rspec'
require 'vcr'

HIJACK_HTTP_REQUESTS_WITH_VCR = ENV['STORMPATH_SDK_TEST_ENVIRONMENT'] != 'CI'

WebMock.allow_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_request { |r| HIJACK_HTTP_REQUESTS_WITH_VCR != true }
end

module Stormpath
  module TestApiKeyHelpers
    TEST_ENV_REQUIRED_VARS = {
      STORMPATH_SDK_TEST_API_KEY_ID: 'The id form your Stormpath API Key',
      STORMPATH_SDK_TEST_API_KEY_SECRET: 'The secret from your Stormpath API Key',
      STORMPATH_SDK_TEST_APPLICATION_URL: 'The REST URL of a Stormpath Application reserved for testing.',
      STORMPATH_SDK_TEST_DIRECTORY_URL: 'The REST URL of a Stormpath Directory associated to the test Application.',
      STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL: 'The REST URL of a Stormpath Directory configured for email verification, associated to the test Application.'
    }

    def test_api_key_id
      ENV['STORMPATH_SDK_TEST_API_KEY_ID']
    end

    def test_api_key_secret
      ENV['STORMPATH_SDK_TEST_API_KEY_SECRET']
    end

    def test_directory_url
      ENV['STORMPATH_SDK_TEST_DIRECTORY_URL']
    end

    def test_directory_with_verification_url
      ENV['STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL']
    end

    def test_application_url
      ENV['STORMPATH_SDK_TEST_APPLICATION_URL']
    end

    def test_api_key
      Stormpath::ApiKey.new test_api_key_id,
        test_api_key_secret
    end

    def test_api_client
      Stormpath::Client.new api_key: test_api_key
    end

    def test_missing_env_vars
      TEST_ENV_REQUIRED_VARS.reject do |var, message|
        ENV[var.to_s]
      end
    end

    def test_application
      test_api_client.applications.get test_application_url
    end

    def test_directory
      test_api_client.directories.get test_directory_url
    end

    def test_directory_with_verification
      test_api_client.directories.get test_directory_with_verification_url
    end
  end

  module TestResourceHelpers

    def destroy_all_stormpath_test_resources api_key
      client = Stormpath::Client.new({
        api_key: api_key
      })

      tenant = client.tenant

      directories = tenant.directories

      directories.each do |dir|
        if dir.name.downcase.start_with? 'test'
          accounts = dir.accounts
          accounts.each do |account|
            account.delete
          end
          dir.delete
        end
      end

      test_directory.accounts.each { |account| account.delete }
      test_directory_with_verification.accounts.each { |account| account.delete }

      applications = tenant.applications

      applications.each do |app|
        app.delete if app.name.downcase.start_with? 'test'
      end
    end

    def build_account(opts={})
      opts.tap do |o|
        o[:surname]    = (!opts[:surname].blank? && opts[:surname]) || 'surname'
        o[:given_name] = (!opts[:given_name].blank? && opts[:given_name]) || 'givenname'
        o[:username]   = (!opts[:username].blank? && opts[:username]) || 'username'
        o[:password]   = (!opts[:password].blank? && opts[:password]) || 'P@$$w0rd'
        o[:email]      = (!opts[:email].blank? && opts[:email]) || 'test@example.com'
      end
    end
  end
end

RSpec.configure do |c|
  c.include Stormpath::TestApiKeyHelpers
  c.include Stormpath::TestResourceHelpers

  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before(:all) do
    unless test_missing_env_vars.empty?
      set_up_message = "In order to run the specs of the Stormpath SDK you need to setup the following environment variables:\n\t"
      set_up_message << test_missing_env_vars.map do |var, message|
        "#{var.to_s} : #{message}"
      end.join("\n\t")
      set_up_message << "\nBe sure to configure these before running the specs again."
      raise set_up_message
    end

    destroy_all_stormpath_test_resources(test_api_key) unless HIJACK_HTTP_REQUESTS_WITH_VCR
  end

  c.after(:all) do
    destroy_all_stormpath_test_resources(test_api_key) unless HIJACK_HTTP_REQUESTS_WITH_VCR
  end
end
