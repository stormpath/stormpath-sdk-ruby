require 'spec_helper'

describe Stormpath::Resource::Directory, :vcr do
  def create_account_store_mapping(application, account_store, is_default_group_store=false)
    test_api_client.account_store_mappings.create({
      application: application,
      account_store: account_store,
      list_index: 0,
      is_default_account_store: true,
      is_default_group_store: is_default_group_store
     })
  end

  describe "instances should respond to attribute property methods" do
    let(:app) { test_api_client.applications.create name: random_application_name, description: 'Dummy desc.' }
    let(:application) { test_api_client.applications.get app.href }
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }
    let(:directory_with_verification) { test_directory_with_verification }

    before do
      test_api_client.account_store_mappings.create({ application: app, account_store: directory_with_verification,
        list_index: 1, is_default_account_store: false, is_default_group_store: false })
    end

    after do
      directory.delete if directory
      application.delete if application
    end

    it do
      expect(directory).to be_a Stormpath::Resource::Directory

      [:name, :description, :status].each do |property_accessor|
        expect(directory).to respond_to(property_accessor)
        expect(directory).to respond_to("#{property_accessor}=")
        expect(directory.send property_accessor).to be_a String
      end

      [:created_at, :modified_at].each do |property_getter|
        expect(directory).to respond_to(property_getter)
        expect(directory.send property_getter).to be_a String
      end

      expect(directory.tenant).to be_a Stormpath::Resource::Tenant
      expect(directory.groups).to be_a Stormpath::Resource::Collection
      expect(directory.accounts).to be_a Stormpath::Resource::Collection
      expect(directory.custom_data).to be_a Stormpath::Resource::CustomData
    end
  end

  describe 'directory_associations' do
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }

    after do
      directory.delete if directory
    end

    context '#accounts' do
      let(:account) { directory.accounts.create build_account}

      after do
        account.delete if account
      end

      it 'should be able to create an account' do
        expect(directory.accounts).to include(account)
      end

      it 'should be able to create and fetch the account' do
        expect(directory.accounts.get account.href).to be
      end
    end

    context '#groups' do
      let(:group) { directory.groups.create name: random_group_name }

      after do
        group.delete if group
      end

      it 'should be able to create a group' do
        expect(directory.groups).to include(group)
      end

      it 'should be able to create and get a group' do
        expect(directory.groups.get group.href).to be
      end
    end

    context '#organizations' do
      let(:organization) do
        test_api_client.organizations.create(name: 'Test organization name',
                                             name_key: 'test-organization-name-key')
      end

      let!(:organization_account_store_mappings) do
        test_api_client.organization_account_store_mappings.create(
          account_store: { href: directory.href },
          organization: { href: organization.href }
        )
      end

      after do
        organization.delete
      end

      it 'should be able to get organizations' do
        expect(directory.organizations).to include(organization)
      end

      it 'should be able to get specific organization with organization href' do
        expect(directory.organizations.get(organization.href)).to eq organization
      end
    end

    context '#password_policy' do
      it 'should be able to fetch the password policy' do
        expect(directory.password_policy).to be_kind_of(Stormpath::Resource::PasswordPolicy)
      end
    end
  end

  describe '#create_account' do
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }

    let(:account) do
      Stormpath::Resource::Account.new({
        email: random_email,
        given_name: 'Ruby SDK',
        password: 'P@$$w0rd',
        surname: 'SDK',
        username: random_user_name
      })
    end

    after do
      directory.delete if directory
    end

    context 'without registration workflow' do

      let(:created_account) { directory.create_account account }

      after do
        created_account.delete if created_account
      end

      it 'creates an account with status ENABLED' do
        expect(created_account).to be
        expect(created_account.username).to eq(account.username)
        expect(created_account).to eq(account)
        expect(created_account.status).to eq("ENABLED")
        expect(created_account.email_verification_token).not_to be
      end
    end

    context 'with registration workflow' do

      let(:created_account_with_reg_workflow) { test_directory_with_verification.create_account account }

      after do
        created_account_with_reg_workflow.delete if created_account_with_reg_workflow
      end

      it 'creates an account with status UNVERIFIED' do
        expect(created_account_with_reg_workflow).to be
        expect(created_account_with_reg_workflow.username).to eq(account.username)
        expect(created_account_with_reg_workflow).to eq(account)
        expect(created_account_with_reg_workflow.status).to eq("UNVERIFIED")
        expect(created_account_with_reg_workflow.email_verification_token.href).to be
      end

    end

    context 'with registration workflow but set it to false on account creation' do
      let(:created_account_with_reg_workflow) { test_directory_with_verification.create_account account, false }

      after do
        created_account_with_reg_workflow.delete if created_account_with_reg_workflow
      end

      it 'creates an account with status ENABLED' do
        expect(created_account_with_reg_workflow).to be
        expect(created_account_with_reg_workflow.username).to eq(account.username)
        expect(created_account_with_reg_workflow).to eq(account)
        expect(created_account_with_reg_workflow.status).to eq("ENABLED")
        expect(created_account_with_reg_workflow.email_verification_token).not_to be
      end
    end
  end

  describe 'create account with password import MCF feature' do
    let(:app) { test_api_client.applications.create name: random_application_name, description: 'Dummy desc.' }
    let(:application) { test_api_client.applications.get app.href }
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }
    let!(:account_store_mapping) {create_account_store_mapping(application,directory,true)}

    after do
      application.delete if application
      directory.delete if directory
      @account.delete if @account
    end

    context "MD5 hashing algorithm" do
      before do
        account_store_mapping
        @account = directory.accounts.create({
          username: "jlucpicard",
          email: "captain@enterprise.com",
          given_name: "Jean-Luc",
          surname: "Picard",
          password: "$stormpath2$MD5$1$OGYyMmM5YzVlMDEwODEwZTg3MzM4ZTA2YjljZjMxYmE=$EuFAr2NTM83PrizVAYuOvw=="
        }, password_format: 'mcf')
      end

      it 'creates an account' do
        expect(@account).to be_a Stormpath::Resource::Account
        expect(@account.username).to eq("jlucpicard")
        expect(@account.email).to eq("captain@enterprise.com")
        expect(@account.given_name).to eq("Jean-Luc")
        expect(@account.surname).to eq("Picard")
      end

      it 'can authenticate with the account credentials' do
        auth_request = Stormpath::Authentication::UsernamePasswordRequest.new 'jlucpicard', 'qwerty'
        auth_result = application.authenticate_account auth_request

        expect(auth_result).to be_a Stormpath::Authentication::AuthenticationResult
        expect(auth_result.account).to be_a Stormpath::Resource::Account
        expect(auth_result.account.email).to eq("captain@enterprise.com")
        expect(auth_result.account.given_name).to eq("Jean-Luc")
        expect(auth_result.account.surname).to eq("Picard")
      end
    end

    context "SHA-512 hashing algorithm" do
      before do
        account_store_mapping
        @account = directory.accounts.create({
          username: "jlucpicard",
          email: "captain@enterprise.com",
          given_name: "Jean-Luc",
          surname: "Picard",
          password: "$stormpath2$SHA-512$1$ZFhBRmpFSnEwVEx2ekhKS0JTMDJBNTNmcg==$Q+sGFg9e+pe9QsUdfnbJUMDtrQNf27ezTnnGllBVkQpMRc9bqH6WkyE3y0svD/7cBk8uJW9Wb3dolWwDtDLFjg=="
        }, password_format: 'mcf')
      end

      it 'creates an account' do
        expect(@account).to be_a Stormpath::Resource::Account
        expect(@account.username).to eq("jlucpicard")
        expect(@account.email).to eq("captain@enterprise.com")
        expect(@account.given_name).to eq("Jean-Luc")
        expect(@account.surname).to eq("Picard")
      end

      it 'can authenticate with the account credentials' do
        auth_request = Stormpath::Authentication::UsernamePasswordRequest.new 'jlucpicard', 'testing12'
        auth_result = application.authenticate_account auth_request

        expect(auth_result).to be_a Stormpath::Authentication::AuthenticationResult
        expect(auth_result.account).to be_a Stormpath::Resource::Account
        expect(auth_result.account.email).to eq("captain@enterprise.com")
        expect(auth_result.account.given_name).to eq("Jean-Luc")
        expect(auth_result.account.surname).to eq("Picard")
      end
    end

    context "BCrypt 2A hashing algorithm" do
      before do
        account_store_mapping
        @account = directory.accounts.create({
          username: "jlucpicard",
          email: "captain@enterprise.com",
          given_name: "Jean-Luc",
          surname: "Picard",
          password: "$2a$10$sWvxHJIvkARbp.u2yBpuJeGzNvpxYQo7AYxAJwFRH0HptXSWyqvwy"
        }, password_format: 'mcf')
      end

      it 'creates an account' do
        expect(@account).to be_a Stormpath::Resource::Account
        expect(@account.username).to eq("jlucpicard")
        expect(@account.email).to eq("captain@enterprise.com")
        expect(@account.given_name).to eq("Jean-Luc")
        expect(@account.surname).to eq("Picard")
      end

      it 'can authenticate with the account credentials' do
        auth_request = Stormpath::Authentication::UsernamePasswordRequest.new 'jlucpicard', 'NotSecure'
        auth_result = application.authenticate_account auth_request

        expect(auth_result).to be_a Stormpath::Authentication::AuthenticationResult
        expect(auth_result.account).to be_a Stormpath::Resource::Account
        expect(auth_result.account.email).to eq("captain@enterprise.com")
        expect(auth_result.account.given_name).to eq("Jean-Luc")
        expect(auth_result.account.surname).to eq("Picard")
      end
    end

    context 'with account data as hash' do
      let(:account_email) { random_email }

      let(:created_account_with_hash) do
        directory.create_account({
          email: account_email,
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: random_user_name
        })
      end

      after do
        created_account_with_hash.delete if created_account_with_hash
      end

      it 'creates an account with status ENABLED' do
        expect(created_account_with_hash.email).to eq(account_email)
        expect(created_account_with_hash.given_name).to eq('Ruby SDK')
        expect(created_account_with_hash.surname).to eq('SDK')
        expect(created_account_with_hash.status).to eq("ENABLED")
      end
    end

  end

  describe '#create_directory_with_custom_data' do
    let(:directory_name) { random_directory_name }

    let(:directory) { test_api_client.directories.create name: directory_name, description: 'description_for_some_test_directory' }

    after do
      directory.delete if directory
    end

    it 'creates an directory with custom data' do
      directory.custom_data["category"] = "classified"

      directory.save
      expect(directory.name).to eq(directory_name)
      expect(directory.description).to eq('description_for_some_test_directory')
      expect(directory.custom_data["category"]).to eq("classified")
    end
  end

  describe 'create directory with provider data' do
    context 'valida data' do
      let(:directory) do
        test_api_client.directories.create(
          name: random_directory_name,
          description: 'description_for_some_test_directory',
          provider: {
            provider_id: "saml",
            sso_login_url:"https://yourIdp.com/saml2/sso/login",
            sso_logout_url:"https://yourIdp.com/saml2/sso/logout",
            encoded_x509_signing_cert:"-----BEGIN CERTIFICATE-----\n...Certificate goes here...\n-----END CERTIFICATE-----",
            request_signature_algorithm:"RSA-SHA256"
          }
        )
      end

      after do
        directory.delete if directory
      end

      it 'creates the directory with provider data' do
        stub_request(:post, "https://api.stormpath.com/v1/directories").
          to_return(status:200, body:  fixture('create_saml_directory.json'), headers:{})

        stub_request(:get, directory.href + "/provider").
          to_return(status: 200, body: fixture('get_saml_directory_provider.json'), headers:{})

        directory
        expect(directory.provider.provider_id).to eq("saml")
        expect(directory.provider.sso_login_url).to eq("https://yourIdp.com/saml2/sso/login")
        expect(directory.provider.sso_logout_url).to eq("https://yourIdp.com/saml2/sso/logout")
        expect(directory.provider.request_signature_algorithm).to eq("RSA-SHA256")
      end
    end

    context 'invalid data' do
      it 'raises Stormpath::Error' do
        expect do
          test_api_client.directories.create(
            name: random_directory_name,
            description: 'description_for_some_test_directory',
            provider: {
              provider_id: "saml",
              sso_login_url:"",
              sso_logout_url:"",
              encoded_x509_signing_cert:"",
              request_signature_algorithm:"RSA-SHA256"
            }
          )
        end.to raise_error Stormpath::Error
      end
    end
  end

  describe 'saml #provider' do
    let(:directory) do
      test_api_client.directories.create(
        name: random_directory_name,
        description: 'description_for_some_test_directory',
        provider: {
          provider_id: "saml",
          sso_login_url:"https://yourIdp.com/saml2/sso/login",
          sso_logout_url:"https://yourIdp.com/saml2/sso/logout",
          encoded_x509_signing_cert:"-----BEGIN CERTIFICATE-----\n...Certificate goes here...\n-----END CERTIFICATE-----",
          request_signature_algorithm:"RSA-SHA256"
        }
      )
    end

    after do
      directory.delete if directory
    end

    it 'returnes provider data' do
      stub_request(:post, "https://api.stormpath.com/v1/directories").
        to_return(status:200, body: fixture('create_saml_directory.json'), headers:{})

      stub_request(:get, directory.href + "/provider").
        to_return(status: 200, body: fixture('get_saml_directory_provider.json'), headers:{})

      directory
      expect(directory.provider.href).not_to be_empty
      expect(directory.provider.provider_id).to eq("saml")
      expect(directory.provider.sso_login_url).to eq("https://yourIdp.com/saml2/sso/login")
      expect(directory.provider.sso_logout_url).to eq("https://yourIdp.com/saml2/sso/logout")
      expect(directory.provider.encoded_x509_signing_cert).not_to be_empty
      expect(directory.provider.request_signature_algorithm).to eq("RSA-SHA256")
    end
  end

  describe 'saml #provider_metadata' do
    let(:directory) do
      test_api_client.directories.create(
        name: random_directory_name,
        description: 'description_for_some_test_directory',
        provider: {
          provider_id: "saml",
          sso_login_url:"https://yourIdp.com/saml2/sso/login",
          sso_logout_url:"https://yourIdp.com/saml2/sso/logout",
          encoded_x509_signing_cert:"-----BEGIN CERTIFICATE-----\n...Certificate goes here...\n-----END CERTIFICATE-----",
          request_signature_algorithm:"RSA-SHA256"
        }
      )
    end

    after do
      directory.delete if directory
    end

    it 'returnes provider metadata' do
      stub_request(:post, "https://api.stormpath.com/v1/directories").
        to_return(status:200, body: fixture('create_saml_directory.json'), headers:{})

      stub_request(:get, directory.href + "/provider").
        to_return(status: 200, body: fixture('get_saml_directory_provider.json'), headers:{})

      stub_request(:get, directory.provider.service_provider_metadata["href"]).
        to_return(status: 200, body: fixture('get_saml_directory_provider_metadata.json'), headers: {})

      expect(directory.provider_metadata.href).not_to be_empty
      expect(directory.provider_metadata.entity_id).not_to be_empty
      expect(directory.provider_metadata.assertion_consumer_service_post_endpoint).not_to be_empty
      expect(directory.provider_metadata.x509_signing_cert).not_to be_empty
    end
  end

  describe 'saml mapping rules' do
    let(:directory) do
      test_api_client.directories.create(
        name: random_directory_name,
        description: 'description_for_some_test_directory',
        provider: {
          provider_id: "saml",
          sso_login_url:"https://yourIdp.com/saml2/sso/login",
          sso_logout_url:"https://yourIdp.com/saml2/sso/logout",
          encoded_x509_signing_cert:"-----BEGIN CERTIFICATE-----\n...Certificate goes here...\n-----END CERTIFICATE-----",
          request_signature_algorithm:"RSA-SHA256"
        }
      )
    end

    after do
      directory.delete if directory
    end

    it 'updates the directory mappings' do
      mappings = Stormpath::Provider::SamlMappingRules.new(items: [
        {
          name: "uid",
          account_attributes: ["username"]
        }
      ])

      stub_request(:post, "https://api.stormpath.com/v1/directories").
        to_return(status:200, body: fixture('create_saml_directory.json'), headers:{})

      stub_request(:get, directory.href + "/provider").
        to_return(status: 200, body: fixture('get_saml_directory_provider.json'), headers:{})

      stub_request(:post, directory.provider.attribute_statement_mapping_rules["href"]).
        to_return(status:200, body: fixture('create_saml_directory_mapping_rules.json'), headers:{})

      response = directory.create_attribute_mappings(mappings)
      expect(response.items).to eq( [ { "name" => "uid4", "name_format" => "nil", "account_attributes" => ["username"] } ] )
    end

  end

  describe '#create_account_with_custom_data' do
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }

    after do
      directory.delete if directory
    end

      it 'creates an account with custom data' do
        account =  Stormpath::Resource::Account.new({
          email: random_email,
          given_name: 'Ruby SDK',
          password: 'P@$$w0rd',
          surname: 'SDK',
          username: random_user_name
        })

        account.custom_data["birth_date"] = "2305-07-13"

        created_account = directory.create_account account

        expect(created_account).to be
        expect(created_account.username).to eq(account.username)
        expect(created_account).to eq(account)
        expect(created_account.custom_data["birth_date"]).to eq("2305-07-13")
        created_account.delete
    end
  end

  describe '#create_group' do
    let(:directory) { test_api_client.directories.create name: random_directory_name, description: 'description_for_some_test_directory' }

    after do
      directory.delete if directory
    end

    context 'given a valid group' do
      let(:group_name) { "valid_test_group" }

      let(:created_group) { directory.groups.create name: group_name }

      after do
        created_group.delete if created_group
      end

      it 'creates a group' do
        expect(created_group).to be
        expect(created_group.name).to eq(group_name)
      end
    end
  end

  describe '#delete_directory' do

    let(:directory) { test_api_client.directories.create name: random_directory_name }

    let(:application) { test_api_client.applications.create name: random_application_name }

    let!(:group) { directory.groups.create name: 'someGroup' }

    let!(:account) { directory.accounts.create({ email: 'rubysdk@example.com', given_name: 'Ruby SDK', password: 'P@$$w0rd',surname: 'SDK' }) }

    let!(:account_store_mapping) do
      test_api_client.account_store_mappings.create({ application: application, account_store: directory })
    end

    after do
      application.delete if application
      directory.delete if directory
    end

    it 'and all of its associations' do
      expect(directory.groups.count).to eq(1)
      expect(directory.accounts.count).to eq(1)

      expect(application.account_store_mappings.first.account_store).to eq(directory)

      expect(application.accounts).to include(account)
      expect(application.groups).to include(group)

      expect(application.account_store_mappings.count).to eq(1)

      directory.delete

      expect(application.account_store_mappings.count).to eq(0)

      expect(application.accounts).not_to include(account)
      expect(application.groups).not_to include(group)
    end
  end
end
