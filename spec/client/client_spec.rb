require 'spec_helper'

describe Stormpath::Client do
  describe '.new' do
    let(:test_api_key_id) { ENV['STORMPATH_TEST_API_KEY_ID'] }
    let(:test_api_key_secret) { ENV['STORMPATH_TEST_API_KEY_SECRET'] }

    before do
      unless test_api_key_id and test_api_key_secret
        raise <<needs_setup
In order to run these tests, you need to define the
STORMPATH_TEST_API_KEY_ID and STORMPATH_TEST_API_KEY_SECRET
needs_setup
      end
    end

    shared_examples 'a valid client' do
      it 'can connect successfully' do
        client.should be
        client.should be_kind_of Stormpath::Client
        client.current_tenant.should be
        client.current_tenant.should be_kind_of Stormpath::Tenant
      end
    end

    context 'given a hash' do
      context 'with an api key file location', 'that points to a remote file' do
        let(:api_key_file_location) { 'http://fake.server.com/apiKey.properties' }
        let(:client) { Stormpath::Client.new(api_key_file_location: api_key_file_location) }

        before do
          stub_request(:any, api_key_file_location).to_return(body:<<properties
apiKey.id=#{test_api_key_id}
apiKey.secret=#{test_api_key_secret}
properties
                                                              )
        end

        it_behaves_like 'a valid client'
      end

      context 'with an api key file location', 'that points to a file' do
        after do
          File.delete(api_key_file_location) if File.exists?(api_key_file_location)
        end

        context 'by default' do
          let(:api_key_file_location) do
            File.join(File.dirname(__FILE__), 'foo.properties')
          end
          let(:client) { Stormpath::Client.new(api_key_file_location: api_key_file_location) }

          before do
            File.open(api_key_file_location, 'w') do |f|
              f.write <<properties
apiKey.id=#{test_api_key_id}
apiKey.secret=#{test_api_key_secret}
properties
            end
          end

          it_behaves_like 'a valid client'
        end

        context 'and with an api id property name' do
          let(:api_key_file_location) do
            File.join(File.dirname(__FILE__), 'testApiKey.fooId.properties')
          end
          let(:client) do
            Stormpath::Client.new({
              api_key_file_location: api_key_file_location,
              api_key_id_property_name: 'foo.id'
            })
          end

          before do
            File.open(api_key_file_location, 'w') do |f|
              f.write <<properties
foo.id=#{test_api_key_id}
apiKey.secret=#{test_api_key_secret}
properties
            end
          end

          it_behaves_like 'a valid client'
        end

        context 'and with an api secret property name' do
          let(:api_key_file_location) do
            File.join(File.dirname(__FILE__), 'testApiKey.barBazSecret.properties')
          end
          let(:client) do
            Stormpath::Client.new({
              api_key_file_location: api_key_file_location,
              api_key_secret_property_name: 'bar.baz'
            })
          end

          before do
            File.open(api_key_file_location, 'w') do |f|
              f.write <<properties
apiKey.id=#{test_api_key_id}
bar.baz=#{test_api_key_secret}
properties
            end
          end

          it_behaves_like 'a valid client'
        end

        context 'but there is no api key id property' do
          let(:api_key_file_location) do
            File.join(File.dirname(__FILE__), 'testApiKey.noApiKeyId.properties')
          end
          let(:client) do
            Stormpath::Client.new({
              api_key_file_location: api_key_file_location,
            })
          end

          before do
            File.open(api_key_file_location, 'w') do |f|
              f.write <<properties
foo.id=#{test_api_key_id}
apiKey.secret=#{test_api_key_secret}
properties
            end
          end

          it 'raises an error' do
            expect { client }.to raise_error ArgumentError,
              "No API id in properties. Please provide a 'apiKey.id' property in '" +
              api_key_file_location +
              "' or pass in an 'api_key_id_property_name' to the Stormpath::Client " +
              "constructor to specify an alternative propeety."
          end
        end

        context 'but there is no api key secret property' do
          let(:api_key_file_location) do
            File.join(File.dirname(__FILE__), 'testApiKey.noApiKeySecret.properties')
          end
          let(:client) do
            Stormpath::Client.new({
              api_key_file_location: api_key_file_location,
            })
          end

          before do
            File.open(api_key_file_location, 'w') do |f|
              f.write <<properties
apiKey.id=#{test_api_key_id}
properties
            end
          end

          it 'raises an error' do
            expect { client }.to raise_error ArgumentError,
              "No API secret in properties. Please provide a 'apiKey.secret' property in '" +
              api_key_file_location +
              "' or pass in an 'api_key_secret_property_name' to the Stormpath::Client " +
              "constructor to specify an alternative propeety."
          end
        end

        context 'but there was a problem reading the file' do
          let(:api_key_file_location) do
            'no_such_file'
          end
          let(:client) do
            Stormpath::Client.new({
              api_key_file_location: api_key_file_location,
            })
          end

          it 'raises an error' do
            expect { client }.to raise_error ArgumentError,
              "No API Key file could be found or loaded from '" +
              api_key_file_location +
              "'."
          end
        end
      end

      context 'with a base url' do
        it 'creates a client that connects to that base'
      end

      context 'with an api key' do
        context 'as a Stormpath::ApiKey' do
          let(:api_key) { Stormpath::ApiKey.new(test_api_key_id, test_api_key_secret) }
          let(:client) { Stormpath::Client.new(api_key: api_key) }

          it_behaves_like 'a valid client'
        end

        context 'as a hash' do
          let(:client) do
            Stormpath::Client.new({
              api_key: { id: test_api_key_id,
                         secret: test_api_key_secret
              }
            })
          end

          it_behaves_like 'a valid client'
        end
      end

      context 'with no api key', 'and no api key file location' do
        it 'raises an error' do
          expect { Stormpath::Client.new({}) }.to raise_error ArgumentError,
            /^No API key has been provided\./
        end
      end
    end

    context 'given a Stormpath Application URL' do
      context 'with an embedded API credentials' do
      end

      context 'with no embedded API credentials' do
      end
    end
  end
end
