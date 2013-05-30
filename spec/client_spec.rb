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
    end
  end

  describe '#applications' do
    context 'given a collection' do
      let(:applications) do
        test_api_client.applications
      end

      before do
        applications.create(
          name: 'Client Applications Test',
          description: 'A test description'
        )
      end

      it 'returns the collection' do
        applications.should be_kind_of(Stormpath::Resource::Collection)
        applications.count.should have_at_least(1).item
      end
    end

    describe '.create' do
      let(:application_attributes) do
        {
          name: 'Client Application Create Test',
          description: 'A test description'
        }
      end

      let(:created_application) do
        test_api_client.applications.create application_attributes
      end

      it 'creates that application' do
        created_application.should be
        created_application.name.should == application_attributes[:name]
        created_application.description.should == application_attributes[:description]
      end
    end
  end

  describe '#directories' do
    context 'given a collection' do
      let(:directories) do
        test_api_client.directories
      end

      before do
        directories.create(
          name: 'Client Directories Test',
          description: 'A test description'
        )
      end

      it 'returns the collection' do
        directories.should be_kind_of(Stormpath::Resource::Collection)
        directories.count.should have_at_least(1).item
      end
    end

    describe '.create' do
      let(:directory_attributes) do
        {
          name: 'Client Directory Create Test',
          description: 'A test description'
        }
      end

      let(:created_directory) do
        test_api_client.directories.create directory_attributes
      end

      it 'creates that application' do
        created_directory.should be
        created_directory.name.should == directory_attributes[:name]
        created_directory.description.should == directory_attributes[:description]
      end
    end
  end

  describe '#accounts.verify_account_email' do
    context 'given a verfication token of an account' do
      let(:directory) { test_directory_with_verification }
      let(:account) do
        account = Stormpath::Resource::Account.new({
          email: "test@example.com",
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: "testusername"
        })
        directory.create_account account
      end
      let(:verification_token) do
        account.email_verification_token.token
      end
      let(:verified_account) do
        test_api_client.accounts.verify_email_token verification_token
      end

      after do
        account.delete if account
      end

      it 'returns the account' do
        verified_account.should be
        verified_account.should be_kind_of Stormpath::Resource::Account
        verified_account.username.should == account.username
      end
    end
  end
end
