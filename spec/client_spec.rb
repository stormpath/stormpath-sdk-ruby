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
        context 'creates a client that connects to that base' do
          let(:api_key) { Stormpath::ApiKey.new(test_api_key_id, test_api_key_secret) }
          let(:client) { Stormpath::Client.new(api_key: api_key, base_url: "https://api.stormpath.com/v1") }

          it_behaves_like 'a valid client'
        end
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

    context 'with an http proxy specified' do
      let(:http_proxy) do
        'http://exampleproxy.com:8080'
      end

      let(:request_executor) do
        Stormpath::Test::TestRequestExecutor.new
      end

      let(:api_key) do
        Stormpath::ApiKey.new test_api_key_id, test_api_key_secret
      end

      it 'initializes the request executor with the proxy' do
        expect(Stormpath::Http::HttpClientRequestExecutor)
          .to receive(:new)
          .with(proxy: http_proxy)
          .and_return request_executor

        Stormpath::Client.new api_key: api_key, proxy: http_proxy
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
        expect(applications.count).to be >= 1
      end

      after do
        application.delete
      end
    end

    context 'pagination' do
      let!(:applications) do
        (0..2).to_a.map do |index|
          test_api_client.applications.create name: random_application_name(index), description: 'foo'
        end
      end

      it 'accepts offset and limit' do
        expect(test_api_client.applications.limit(2).count).to be >= 3
        expect(test_api_client.applications.offset(1).limit(2).count).to be >= 2
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
        client.directories.create name: random_directory_name
      end

      let(:group) do
        directory.groups.create name: random_group_name
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
          directory.groups.create name: random_group_name
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
      let(:first_application_name) { random_application_name(1) }
      let(:second_application_name) { random_application_name(2) }

      let!(:applications) do
        [
          test_api_client.applications.create(name: first_application_name, description: 'foo'),
          test_api_client.applications.create(name: second_application_name, description: 'foo')
        ]
      end

      context 'by any attribute' do
        let(:search_results) do
          test_api_client.applications.search(first_application_name)
        end

        it 'returns the application' do
          expect(search_results.count).to eq 1
        end
      end

      context 'by an explicit attribute' do
        let(:search_results) do
          test_api_client.applications.search(name: first_application_name)
        end

        it 'returns the application' do
          expect(search_results.count).to eq 1
        end
      end

      after do
        applications.each do |application|
          application.delete
        end
      end
    end

    describe '.create' do
      let(:application_name) { random_application_name }

      let(:application_attributes) do
        {
          name: application_name,
          description: 'A test description'
        }
      end

      context do
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

      describe 'auto directory creation' do
        let(:application) { test_api_client.applications.create application_attributes, options }

        let(:directories) do
          test_api_client.directories
        end

        context 'login source' do
          let(:options) { { createDirectory: true } }

          let!(:account) do
            application.accounts.create(
                given_name: 'John',
                surname: 'Smith 2',
                email: 'john.smith2@example.com',
                username: 'johnsmith2',
                password: '4P@$$w0rd!'
            )
          end

          before { application }

          it 'serves as the accounts store and login source' do
            auth_request = Stormpath::Authentication::UsernamePasswordRequest.new 'johnsmith2', '4P@$$w0rd!'
            auth_result = application.authenticate_account auth_request
            expect(account).to eq(auth_result.account)
          end
        end

        context 'with directory: true' do
          let(:options) { { createDirectory: true } }

          it 'creates directory named by appending "Directory" to app name' do
            application
            expect(directories.map(&:name)).to include("#{application_name} Directory")
          end

          context 'and existing directory' do
            it 'resolves naming conflict by adding (n) to directory name' do
              test_api_client.directories.each { |d| d.delete if "#{application_name} Directory" == d.name }
              test_api_client.directories.create({name: "#{application_name} Directory"})
              application
              expect(directories.map(&:name)).to include("#{application_name} Directory (2)")
            end
          end
        end

        context 'with directory: "Client Application Create Test Directory"' do
          let(:options) { { createDirectory: true } }

          before { application }

          #fails with Stormpath::Error: Authentication required.
          it 'creates directory named "Client Application Create Test Directory"' do
            expect(directories.map(&:name)).to include("#{application_name} Directory")
          end

          it 'resolves naming conflict with existing directory throwing Stormpath::Error with status 409 and code 5010'
        end

        context 'with directory: ""' do
          let(:options) { { createDirectory: '' } }

          it 'throws Stormpath::Error with status 400 and code 2000', skip_cleanup: true do
            expect { application }.to raise_error { |error|
              expect(error).to be_a(Stormpath::Error)
              expect(error.status).to eq(400)
              expect(error.code).to eq(2000)
            }
          end
        end

        context 'with directory: false' do
          let(:options) { { createDirectory: false } }

          before { application }

          it 'creates no directory' do
            expect(directories.map(&:name)).not_to include("#{application_name} Directory")
          end
        end

        after(:each) do |example|
          unless example.metadata[:skip_cleanup]
            application.delete
            test_api_client.directories.each do |d|
              d.delete if ["#{application_name} Directory", "#{application_name} Directory (2)", "#{application_name} Directory Custom"].include?(d.name)
            end
          end
        end
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
        expect(directories.count).to be >= 1
      end

      after do
        directory.delete
      end
    end

    context 'given a collection with a limit' do
      let!(:directory_1) do
        test_api_client.directories.create name: random_directory_name(1)
      end

      let!(:directory_2) do
        test_api_client.directories.create name: random_directory_name(2)
      end

      after do
        directory_1.delete if directory_1
        directory_2.delete if directory_2
      end

      it 'should retrieve the number of directories described with the limit' do
        expect(test_api_client.directories.count).to be >= 2
      end
    end

    describe '.create' do

      let(:directory_name) { random_directory_name }

      let(:directory_attributes) do
        {
          name: directory_name,
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

  describe '#organization' do
    context 'search' do
      let(:organization_name) { random_organization_name }

      let!(:organization) do
        test_api_client.organizations.create(
          name: organization_name,
          name_key: "testorganization"
        )
      end

      context 'by any attribute' do
        let(:search_results) do
          test_api_client.organizations.search(organization_name)
        end

        it 'returns the application' do
          expect(search_results.count).to eq 1
        end
      end

      context 'by an explicit attribute' do
        let(:search_results) do
          test_api_client.organizations.search(name: random_organization_name)
        end

        it 'returns the application' do
          expect(search_results.count).to eq 1
        end
      end

      after { organization.delete }
    end

    context 'given a collection' do
      let(:organization) do
        test_api_client.organizations.create(
            name: random_organization_name,
            name_key: random_name_key,
            description: 'A test description'
        )
      end

      it 'returns the collection' do
        expect(test_api_client.organizations).to be_kind_of(Stormpath::Resource::Collection)
        expect(test_api_client.organizations.count).to be >= 1
      end

      after { organization.delete }
    end

    context 'given a collection with a limit' do
      let!(:organization_1) do
        test_api_client.organizations.create name: random_organization_name(1), name_key: random_name_key(1)
      end

      let!(:organization_2) do
        test_api_client.organizations.create name: random_organization_name(2), name_key: random_name_key(2)
      end

      after do
        organization_1.delete
        organization_2.delete
      end

      it 'should retrieve the number of organizations described with the limit' do
        expect(test_api_client.organizations.count).to be >= 2
      end
    end

    describe '.create' do
      let(:organization_name) { random_organization_name }

      let(:organization_attributes) do
        {
          name: organization_name,
          name_key: random_name_key,
          description: 'A test description'
        }
      end

      let(:organization) do
        test_api_client.organizations.create organization_attributes
      end

      it 'creates an organization' do
        expect(organization).to be
        expect(organization.name).to eq(organization_attributes[:name])
        expect(organization.name_key).to eq(organization_attributes[:name_key])
        expect(organization.description).to eq(organization_attributes[:description])
      end

      after do
        organization.delete
      end
    end
  end

  describe "#organization_account_store_mappings" do
    let(:organization) do
      test_api_client.organizations.create name: 'test_organization',
      name_key: "testorganization"
    end

    let(:directory) { test_api_client.directories.create name: random_directory_name }

    let(:organization_account_store_mappings) do
      test_api_client.organization_account_store_mappings.create({
        account_store: { href: directory.href },
        organization: { href: organization.href }
      })
    end

    after do
      organization.delete if organization
      directory.delete if directory
    end

    it "returns the mapping" do
      expect(organization_account_store_mappings.is_default_account_store).to eq(false)
      expect(organization_account_store_mappings.is_default_group_store).to eq(false)
      expect(organization_account_store_mappings.organization).to eq(organization)
      expect(organization_account_store_mappings.list_index).to eq(0)
      expect(organization_account_store_mappings.account_store).to be_kind_of(Stormpath::Resource::Directory)
    end
  end

  describe '#accounts.verify_account_email' do
    context 'given a verfication token of an account' do
      let(:directory) { test_directory_with_verification }

      let(:account) do
        account = Stormpath::Resource::Account.new({
          email: random_email,
          givenName: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: random_user_name
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
