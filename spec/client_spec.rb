require 'spec_helper'
require 'pp'

describe Stormpath::Client, :vcr do
  describe '.new' do
    shared_examples 'a valid client' do
      it 'can connect successfully' do
        client.should be
        client.should be_kind_of Stormpath::Client
        client.tenant.should be
        client.tenant.should be_kind_of Stormpath::Resource::Tenant
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
              "constructor to specify an alternative property."
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
              "constructor to specify an alternative property."
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

      context 'with an application url' do
        let(:application_name) { 'myApplication' }
        let(:api_key) { Stormpath::ApiKey.new(test_api_key_id, test_api_key_secret) }
        let(:application) do
          client = Stormpath::Client.new({
            api_key: api_key
          })
          client.applications.create 'name' => application_name
        end

        after do
          if application
            application.delete
          end
        end

        context 'with embedded API credentials' do
          let(:application_href) do
            uri = URI(application.href)
            credentialed_uri = URI::HTTPS.new(
              uri.scheme, "#{test_api_key_id}:#{test_api_key_secret}", uri.host,
              uri.port, uri.registry, uri.path, uri.query, uri.opaque, uri.fragment
            )
            credentialed_uri.to_s
          end

          let(:client) do
            Stormpath::Client.new({
              application_url: application_href
            })
          end

          it_behaves_like 'a valid client'

          it 'provides access to the application' do
            client.application.should be
            client.application.should be_kind_of Stormpath::Resource::Application
            client.application.name.should == application_name
          end
        end

        context 'without embedded API credentials' do
          context 'and an API key' do
            let(:client) do
              Stormpath::Client.new({
                application_url: application.href,
                api_key: Stormpath::ApiKey.new(test_api_key_id, test_api_key_secret)
              })
            end

            it_behaves_like 'a valid client'

            it 'provides access to the application' do
              client.application.should be
              client.application.should be_kind_of Stormpath::Resource::Application
              client.application.name.should == application_name
            end
          end

          context 'but no API key' do
            let(:client) do
              Stormpath::Client.new({
                application_url: application.href
              })

              it 'raises an error' do
                expect { client }.to raise_error ArgumentError,
                  /^No API key has been provided\./
              end
            end
          end
        end
      end
    end
  end
end
