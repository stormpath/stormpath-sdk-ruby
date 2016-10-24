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

HIJACK_HTTP_REQUESTS_WITH_VCR = ENV['STORMPATH_SDK_TEST_ENVIRONMENT'] != 'CI'

WebMock.allow_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_request { |r| HIJACK_HTTP_REQUESTS_WITH_VCR == false }
end

RSpec::Matchers.define :be_boolean do
  match do |actual|
    actual.should satisfy { |x| x == true || x == false }
  end
end

module Stormpath
  module TestApiKeyHelpers
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
    unless test_missing_required_env_vars.empty?
      warn_message = "\n\n"
      30.times { warn_message << '*' }
      warn_message << 'STORMPATH RUBY SDK'
      42.times { warn_message << '*' }
      warn_message << "\n\n"
      warn_message << Stormpath::TestApiKeyHelpers::TEST_ENV_VARS[:deprecated].map do |var, message|
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
