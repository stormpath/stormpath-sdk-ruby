# Note: If SimpleCov starts after your application code is already loaded (via require),
# it won't be able to track your files and their coverage! The SimpleCov.start must be
# issued before any of your application code is required!
require 'simplecov'
SimpleCov.start do
  add_filter { |src| src.filename =~ /spec/ }
end

require 'stormpath-sdk'
require 'pry'
require 'webmock/rspec'
require 'vcr'
require 'jwt'
require 'uuidtools'

Dir['./spec/support/*.rb'].each { |file| require file }

WebMock.allow_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  c.before_record do |i|
    i.request.headers.delete('Authorization')
    u = URI.parse(i.request.uri)
    i.request.uri.sub!(/:\/\/.*#{Regexp.escape(u.host)}/, "://#{u.host}" )
  end
end

RSpec::Matchers.define :be_boolean do
  match do |actual|
    actual.should satisfy { |x| x == true || x == false }
  end
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
      Stormpath::ApiKey.new test_api_key_id, test_api_key_secret
    end

    def test_api_client
      @test_api_client ||= Stormpath::Client.new api_key: test_api_key
    end

    def test_host
      Stormpath::DataStore::DEFAULT_SERVER_HOST
    end

    def get_cache_data href
      data_store = test_api_client.send :data_store
      data_store.send :cache_for, href
    end

    def test_missing_env_vars
      TEST_ENV_REQUIRED_VARS.reject do |var, _message|
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

    def fixture_path
      File.expand_path('../fixtures/response', __FILE__)
    end

    def fixture(file)
      File.new(fixture_path + '/' + file)
    end
  end

  module TestResourceHelpers
    def build_account(opts = {})
      opts.tap do |o|
        o[:surname]    = (!opts[:surname].blank? && opts[:surname]) || 'surname'
        o[:given_name] = (!opts[:given_name].blank? && opts[:given_name]) || 'givenname'
        o[:username]   = (!opts[:username].blank? && opts[:username]) || random_user_name
        o[:password]   = (!opts[:password].blank? && opts[:password]) || 'P@$$w0rd'
        o[:email]      = (!opts[:email].blank? && opts[:email]) || random_email
      end
    end
  end

  module RandomResourceNameGenerator
    include UUIDTools

    %w(application directory organization group user).each do |resource|
      define_method "random_#{resource}_name" do |suffix = nil|
        "#{random_string}_#{resource}_#{suffix}"
      end
    end

    def random_name_key(suffix = 'test')
      "#{random_string}-namekey-#{suffix}"
    end

    def random_email
      "#{random_string}@stormpath.com"
    end

    def random_string
      if HIJACK_HTTP_REQUESTS_WITH_VCR
        'test'
      else
        UUID.method(:random_create).call.to_s[0..9]
      end
    end
  end
end

RSpec::Matchers.define :be_boolean do
  match do |actual|
    actual == true || actual == false
  end
end

RSpec.configure do |c|
  c.mock_with :rspec do |c|
    c.syntax = :expect
  end

  c.expect_with :rspec do |c|
    c.syntax = :expect
  end

  c.include Stormpath::TestApiKeyHelpers
  c.include Stormpath::TestResourceHelpers
  c.include Stormpath::RandomResourceNameGenerator

  c.before(:all) do
    unless test_missing_env_vars.empty?
      set_up_message = "In order to run the specs of the Stormpath SDK you need to setup the following environment variables:\n\t"
      set_up_message << test_missing_env_vars.map do |var, message|
        "#{var.to_s} : #{message}"
      end.join("\n\t")
      set_up_message << "\nBe sure to configure these before running the specs again."
      raise set_up_message
    end
  end

end
