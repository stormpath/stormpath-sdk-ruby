require 'spec_helper'
require 'pp'

describe Stormpath::Client, :vcr do
  describe '.new' do
    shared_examples 'a valid client' do
      it 'can connect successfully' do
        expect(client).to be
        expect(client).to be_kind_of Stormpath::Client
        expect(client.tenant).to be
        expect(client.tenant).to be_kind_of Stormpath::Resource::Tenant
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

      context 'with cache configuration' do
        let(:api_key_file_location) { 'http://fake.server.com/apiKey.properties' }
        let(:client) do
          Stormpath::Client.new( {
            api_key_file_location: api_key_file_location,
            cache: {
              store: Stormpath::Test::FakeStore1,
              regions: {
                directories: { ttl_seconds: 40, tti_seconds: 20 },
                groups:      { ttl_seconds: 80, tti_seconds: 40, store: Stormpath::Test::FakeStore2 }
              }
            }
          })
        end

        before do
          stub_request(:any, api_key_file_location).to_return(body:<<properties
apiKey.id=#{test_api_key_id}
apiKey.secret=#{test_api_key_secret}
properties
)
          data_store = client.instance_variable_get '@data_store'
          cache_manager = data_store.cache_manager
          @directories_cache = cache_manager.get_cache 'directories'
          @groups_cache = cache_manager.get_cache 'groups'
        end

        it 'passes those params down to the caches' do
          expect(@directories_cache.instance_variable_get('@ttl_seconds')).to eq(40)
          expect(@directories_cache.instance_variable_get('@tti_seconds')).to eq(20)
          expect(@directories_cache.instance_variable_get('@store')).to be_a(Stormpath::Test::FakeStore1)
          expect(@groups_cache.instance_variable_get('@ttl_seconds')).to eq(80)
          expect(@groups_cache.instance_variable_get('@tti_seconds')).to eq(40)
          expect(@groups_cache.instance_variable_get('@store')).to be_a(Stormpath::Test::FakeStore2)
        end
      end
    end
  end

  describe '#applications' do
    context 'by default' do
      let(:applications) do
        test_api_client.applications
      end

      let(:application) do
        applications.create(
          name: 'Client Applications Test',
          description: 'A test description'
        )
      end

      it 'returns the collection' do
        expect(applications).to be_kind_of(Stormpath::Resource::Collection)
        expect(applications.count).to have_at_least(1).item
      end

      after do
        application.delete
      end
    end

    context 'pagination' do
      let(:applications) do
        (0..2).to_a.map do |index|
          test_api_client.applications.create name: "Pagination Test #{index + 1}", description: 'foo'
        end
      end

      it 'accepts offset and limit' do
        expect(test_api_client.applications.limit(2).count).to eq 2
        expect(test_api_client.applications.offset(2).limit(2).count).to have_at_least(1).item
      end

      after do
        applications.each do |application|
          application.delete
        end
      end
    end

    context 'expansion' do
      let(:client) do
        # every time a client is instantiated a new cache is created, so make
        # sure we use the same client across each "it" block
        test_api_client
      end

      let(:cache_manager) do
        data_store = client.instance_variable_get '@data_store'
        cache_manager = data_store.cache_manager
      end

      let(:accounts_cache_summary) do
        cache_manager.get_cache('accounts').stats.summary
      end

      let(:directories_cache_summary) do
        cache_manager.get_cache('directories').stats.summary
      end

      let(:groups_cache_summary) do
        cache_manager.get_cache('groups').stats.summary
      end

      let(:directory) do
        client.directories.create name: 'testDirectory'
      end

      let(:group) do
        directory.groups.create name: 'someGroup'
      end

      let(:account) do
        directory.accounts.create({
          email: 'rubysdk@example.com',
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: 'rubysdk'
        })
      end

      before do
        group.add_account account
      end

      after do
        group.delete if group
        directory.delete if directory
        account.delete if account
      end

      context 'expanding a nested single resource' do
        let(:cached_account) do
          client.accounts.get account.href, Stormpath::Resource::Expansion.new('directory')
        end

        before do
          client.data_store.initialize_cache(Hash.new)
        end

        it 'caches the nested resource' do
          expect(cached_account.directory.name).to be
          expect(directories_cache_summary).to eq [1, 1, 0, 0, 1]
        end
      end

      context 'expanding a nested collection resource' do
        let(:cached_account) do
          client.accounts.get account.href, Stormpath::Resource::Expansion.new('groups')
        end

        let(:group) do
          directory.groups.create name: 'someGroup'
        end

        before do
          client.data_store.initialize_cache(Hash.new)
        end

        it 'caches the nested resource' do
          expect(cached_account.groups.first.name).to eq(group.name)
          expect(groups_cache_summary).to eq [2, 1, 0, 0, 2]
        end
      end

    end

    context 'search' do
      let!(:applications) do
        [
          test_api_client.applications.create(name: 'Test Alpha', description: 'foo'),
          test_api_client.applications.create(name: 'Test Beta', description: 'foo')
        ]
      end

      it 'finds by any attribute' do
        expect(test_api_client.applications.search('Test Alpha').count).to eq(1)
      end

      it 'finds by an explicit attribute' do
        expect(test_api_client.applications.search(name: 'Test Alpha').count).to eq(1)
      end

      after do
        applications.each do |application|
          application.delete
        end
      end
    end

    describe '.create' do
      let(:application_attributes) do
        {
          name: 'Client Application Create Test',
          description: 'A test description'
        }
      end

      let(:application) do
        test_api_client.applications.create application_attributes
      end

      it 'creates that application' do
        expect(application).to be
        expect(application.name).to eq(application_attributes[:name])
        expect(application.description).to eq(application_attributes[:description])
      end

      after do
        application.delete
      end
    end
  end

  describe '#directories' do
    context 'given a collection' do
      let(:directories) do
        test_api_client.directories
      end

      let(:directory) do
        directories.create(
          name: 'Client Directories Test',
          description: 'A test description'
        )
      end

      it 'returns the collection' do
        expect(directories).to be_kind_of(Stormpath::Resource::Collection)
        expect(directories.count).to have_at_least(1).item
      end

      after do
        directory.delete
      end
    end

    describe '.create' do
      let(:directory_attributes) do
        {
          name: 'Client Directory Create Test',
          description: 'A test description'
        }
      end

      let(:directory) do
        test_api_client.directories.create directory_attributes
      end

      it 'creates that application' do
        expect(directory).to be
        expect(directory.name).to eq(directory_attributes[:name])
        expect(directory.description).to eq(directory_attributes[:description])
      end

      after do
        directory.delete
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
        expect(verified_account).to be
        expect(verified_account).to be_kind_of Stormpath::Resource::Account
        expect(verified_account.username).to eq(account.username)
      end
    end
  end
end
