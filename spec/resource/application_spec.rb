require 'spec_helper'
include UUIDTools

describe Stormpath::Resource::Application, :vcr do
  let(:app) { test_api_client.applications.create(application_attrs) }
  let(:application) { test_api_client.applications.get app.href }
  let(:directory) { test_api_client.directories.create(directory_attrs) }

  before do
    map_account_store(app, directory, 1, true, true)
  end

  after do
    application.delete if application
    directory.delete if directory
  end

  it 'instances should respond to attribute property methods' do

    expect(application).to be_a Stormpath::Resource::Application

    [:name, :description, :status].each do |property_accessor|
      expect(application).to respond_to(property_accessor)
      expect(application).to respond_to("#{property_accessor}=")
      expect(application.send property_accessor).to be_a String
    end

    [:authorized_callback_uris, :authorized_origin_uris].each do |property_accessor|
      expect(application).to respond_to(property_accessor)
      expect(application).to respond_to("#{property_accessor}=")
      expect(application.send property_accessor).to be_a Array
    end

    [:created_at, :modified_at].each do |property_getter|
      expect(application).to respond_to(property_getter)
      expect(application.send property_getter).to be_a String
    end

    expect(application.tenant).to be_a Stormpath::Resource::Tenant
    expect(application.default_account_store_mapping).to be_a Stormpath::Resource::AccountStoreMapping
    expect(application.default_group_store_mapping).to be_a Stormpath::Resource::AccountStoreMapping
    expect(application.custom_data).to be_a Stormpath::Resource::CustomData

    expect(application.groups).to be_a Stormpath::Resource::Collection
    expect(application.accounts).to be_a Stormpath::Resource::Collection
    expect(application.password_reset_tokens).to be_a Stormpath::Resource::Collection
    expect(application.verification_emails).to be_a Stormpath::Resource::Collection
    expect(application.account_store_mappings).to be_a Stormpath::Resource::Collection
  end

  describe '.load' do
    let(:url) do
      uri = URI(application.href)
      credentialed_uri = URI::HTTPS.new(
        uri.scheme, "#{test_api_key_id}:#{test_api_key_secret}", uri.host,
        uri.port, uri.registry, uri.path, uri.query, uri.opaque, uri.fragment
      )
      credentialed_uri.to_s
    end

    it 'raises a LoadError with an invalid url' do
      expect do
        Stormpath::Resource::Application.load 'this is an invalid url'
      end.to raise_error(Stormpath::Resource::Application::LoadError)
    end

    it 'instantiates client and application objects from a composite URL' do
      loaded_application = Stormpath::Resource::Application.load(url)
      expect(loaded_application).to eq(application)
    end
  end

  describe 'application_associations' do

    context '#accounts' do
      let(:account) { application.accounts.create(account_attrs) }

      after do
        account.delete if account
      end

      it 'should be able to create an account' do
        expect(application.accounts).to include(account)
        expect(application.default_account_store_mapping.account_store.accounts).to include(account)
      end

      it 'should be able to create and fetch the account' do
        expect(application.accounts.get account.href).to be
      end
    end

    context '#groups' do
      let(:group) { application.groups.create(group_attrs) }

      after { group.delete }

      it 'should be able to create a group' do
        expect(application.groups).to include(group)
        expect(application.default_group_store_mapping.account_store.groups).to include(group)
      end

      it 'should be able to create and fetch a group' do
        expect(application.groups.get group.href).to be
      end
    end

    context '#web_config' do
      let(:web_config) { application.web_config }

      it 'should have web_config' do
        expect(application.web_config).to be_a Stormpath::Resource::ApplicationWebConfig
      end

      it 'should be able to change config' do
        web_config.status = 'ENABLED'
        web_config.save
        expect(application.web_config.status).to eq 'ENABLED'

        web_config.status = 'DISABLED'
        web_config.save
        expect(application.web_config.status).to eq 'DISABLED'
      end

      it 'changing dns_label should affect domain_name' do
        web_config.dns_label = 'stormtrooper'
        web_config.save
        expect(application.web_config.domain_name).to eq 'stormtrooper.apps.stormpath.io'
      end
    end
  end

  describe 'edit authorized_callback_uris' do
    let(:authorized_callback_uris) { ["https://myapplication.com/whatever/callback", "https://myapplication.com/whatever/callback2"] }

    it 'changes authorized callback uris on application' do
      application.authorized_callback_uris = authorized_callback_uris
      response = application.save

      expect(response).to eq application
      expect(application.authorized_callback_uris).to eq(authorized_callback_uris)
    end
  end

  describe 'edit authorized_origin_uris' do
    let(:authorized_origin_uris) do
      ['https://dnsLabel1.apps.stormpath.io', 'https://dnsLabel2.apps.stormpath.io']
    end

    it 'changes authorized origin uris on application' do
      application.authorized_origin_uris = authorized_origin_uris
      application.save

      expect(application.authorized_origin_uris.size).to eq 3
    end
  end

  describe '#create_account' do
    let(:account) { Stormpath::Resource::Account.new(account_attrs) }

    context 'with registration workflow' do
      it 'creates an account with worflow enabled' do
        response = application.create_account account, true

        expect(response).to be_kind_of Stormpath::Resource::Account
        expect(response.email).to eq(account.email)
      end
    end

    context 'without registration workflow' do
      it 'creates an account with workflow disabled' do
        response = application.create_account account

        expect(response).to be_kind_of Stormpath::Resource::Account
        expect(response.email).to eq(account.email)
      end
    end
  end

  describe '#authenticate_account' do
    let(:account) do
      directory.accounts.create account_attrs(password: 'P@$$w0rd')
    end

    let(:login_request) do
      Stormpath::Authentication::UsernamePasswordRequest.new account.username, password
    end

    let(:authentication_result) do
      application.authenticate_account login_request
    end

    after do
      account.delete if account
    end

    context 'given a valid username and password' do
      let(:password) {'P@$$w0rd' }

      it 'returns an authentication result' do
        expect(authentication_result).to be
        expect(authentication_result.account).to be
        expect(authentication_result.account).to be_kind_of Stormpath::Resource::Account
        expect(authentication_result.account.email).to eq(account.email)
      end
    end

    context 'given an invalid username and password' do
      let(:password) { 'b@dP@$$w0rd' }

      it 'raises an error' do
        expect { authentication_result }.to raise_error Stormpath::Error
      end
    end
  end

  describe '#authenticate_account_with_an_account_store_specified' do
    let(:password) {'P@$$w0rd' }

    let(:authentication_result) { application.authenticate_account login_request }

    after do
      account.delete if account
    end

    context 'given a proper directory' do
      let(:account) { directory.accounts.create account_attrs(password: 'P@$$w0rd') }

      let(:login_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new account.username, password, account_store: directory
      end

      it 'should return an authentication result' do
        expect(authentication_result).to be
        expect(authentication_result.account).to be
        expect(authentication_result.account).to be_kind_of Stormpath::Resource::Account
        expect(authentication_result.account.email).to eq(account.email)
      end
    end

    context 'given a wrong directory' do
      let(:new_directory) { test_api_client.directories.create(directory_attrs) }
      let(:account) { new_directory.accounts.create account_attrs(password: 'P@$$w0rd') }
      let(:login_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new account.username, password, account_store: directory
      end

      after do
        new_directory.delete if new_directory
      end

      it 'raises an error' do
        expect { authentication_result }.to raise_error Stormpath::Error
      end
    end

    context 'given a group' do
      let(:group) {directory.groups.create(group_attrs) }

      let(:account) { directory.accounts.create account_attrs(password: 'P@$$w0rd') }

      let(:login_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new account.username, password, account_store: group
      end

      before do
        map_account_store(application, group, 0, true, false)
      end

      after do
        group.delete if group
      end

      it 'and assigning the account to it, should return a authentication result' do
        group.add_account account
        expect(authentication_result).to be
        expect(authentication_result.account).to be
        expect(authentication_result.account).to be_kind_of Stormpath::Resource::Account
        expect(authentication_result.account.email).to eq(account.email)
      end

      it 'but not assigning the account to, it should raise an error' do
        expect { authentication_result }.to raise_error Stormpath::Error
      end
    end

  end

  describe '#send_password_reset_email' do
    context 'given an email' do
      context 'of an existing account on the application' do
        let(:account) { directory.accounts.create account_attrs  }

        let(:sent_to_account) { application.send_password_reset_email account.email }

        after { account.delete if account }

        it 'sends a password reset request of the account' do
          expect(sent_to_account).to be
          expect(sent_to_account).to be_kind_of Stormpath::Resource::Account
          expect(sent_to_account.email).to eq(account.email)
        end
      end

      context 'of an existing account not mapped to the application' do
        let(:account) { other_directory.accounts.create account_attrs  }
        let(:other_directory) { test_api_client.directories.create(directory_attrs) }

        after do
          account.delete
          other_directory.delete
        end

        it 'sends a password reset request of the account' do
          expect do
            application.send_password_reset_email account.email
          end.to raise_error Stormpath::Error
        end
      end

      context 'of a non exisitng account' do
        it 'raises an exception' do
          expect do
            application.send_password_reset_email "test@example.com"
          end.to raise_error Stormpath::Error
        end
      end

      context 'of an existing account on the application with an account store href' do
        let(:account) { directory.accounts.create account_attrs  }

        let(:sent_to_account) do
          application.send_password_reset_email(account.email, account_store: { href: directory.href })
        end

        after { account.delete if account }

        it 'sends a password reset request of the account' do
          expect(sent_to_account).to be
          expect(sent_to_account).to be_kind_of Stormpath::Resource::Account
          expect(sent_to_account.email).to eq(account.email)
        end
      end

      context 'of an existing account on the application with an account store resource object' do
        let(:account) { directory.accounts.create account_attrs  }

        let(:sent_to_account) do
          application.send_password_reset_email(account.email, account_store: directory)
        end

        after { account.delete if account }

        it 'sends a password reset request of the account' do
          expect(sent_to_account).to be
          expect(sent_to_account).to be_kind_of Stormpath::Resource::Account
          expect(sent_to_account.email).to eq(account.email)
        end
      end

      context 'of an existing account not mapped to the application with an account store href' do
        let(:account) { directory.accounts.create account_attrs  }
        let(:other_directory) { test_api_client.directories.create(directory_attrs) }

        after do
          account.delete
          other_directory.delete
        end

        it 'sends a password reset request of the account' do
          expect do
            application.send_password_reset_email(account.email, account_store: { href: other_directory.href })
          end.to raise_error Stormpath::Error
        end
      end

      context 'of an existing account on the application with a non existant account store organization namekey' do
        let(:account) { directory.accounts.create account_attrs  }

        after do
          account.delete
        end

        it 'sends a password reset request of the account' do
          expect do
            application.send_password_reset_email(account.email, account_store: { name_key: "NoKey" })
          end.to raise_error Stormpath::Error
        end
      end

      context 'of an existing account on the application with a right account store organization namekey' do
        let(:account) { account_directory.accounts.create account_attrs  }
        let(:account_directory) { test_api_client.directories.create(directory_attrs) }

        let(:reloaded_account_directory) do
          test_api_client.directories.get(account_directory.href)
        end

        let(:organization_name_key) { 'ruby-test-org-name-key' }

        let(:organization) do
          test_api_client.organizations.create(
            name: "ruby_test_organization_name",
            name_key: organization_name_key
          )
        end

        let(:sent_to_account) do
          application.send_password_reset_email(account.email, account_store: { name_key: organization.name_key })
        end

        after do
          account.delete
          organization.delete
          reloaded_account_directory.delete
        end

        before do
          map_organization_store(account_directory, organization)
          map_account_store(application, organization, 0, true, true)
        end

        it 'sends a password reset request of the account' do
          expect(sent_to_account).to be
          expect(sent_to_account).to be_kind_of Stormpath::Resource::Account
          expect(sent_to_account.email).to eq(account.email)
        end
      end

      context 'of an existing account on the application with a right account store organization resource object' do
        let(:account) { account_directory.accounts.create account_attrs  }
        let(:account_directory) { test_api_client.directories.create(directory_attrs) }
        let(:reloaded_account_directory) do
          test_api_client.directories.get(account_directory.href)
        end
        let(:organization) { test_api_client.organizations.create(organization_attrs) }
        let(:sent_to_account) do
          application.send_password_reset_email(account.email, account_store: organization)
        end

        after do
          account.delete
          organization.delete
          reloaded_account_directory.delete
        end

        before do
          map_organization_store(account_directory, organization)
          map_account_store(application, organization, 0, true, true)
        end

        it 'sends a password reset request of the account' do
          expect(sent_to_account).to be
          expect(sent_to_account).to be_kind_of Stormpath::Resource::Account
          expect(sent_to_account.email).to eq(account.email)
        end
      end

      context 'of an existing account on the application with a wrong account store organization namekey' do
        let(:account) { account_directory.accounts.create account_attrs  }
        let(:account_directory) { test_api_client.directories.create(directory_attrs) }
        let(:reloaded_account_directory) do
          test_api_client.directories.get(account_directory.href)
        end
        let(:organization) { test_api_client.organizations.create(organization_attrs) }
        let(:other_organization) { test_api_client.organizations.create(organization_attrs) }

        after do
          account.delete
          organization.delete
          other_organization.delete
          reloaded_account_directory.delete
        end

        before do
          map_organization_store(account_directory, organization)
          map_account_store(application, organization, 0, true, true)
        end

        it 'sends a password reset request of the account' do
          expect do
            application.send_password_reset_email(account.email, account_store: { name_key: other_organization.name_key })
          end.to raise_error Stormpath::Error
        end
      end
    end
  end

  describe '#verification_emails' do
    let(:directory_with_verification) { test_api_client.directories.create(directory_attrs) }

    before do
      map_account_store(application, directory_with_verification, 1, false, false)
      enable_email_verification(directory_with_verification)
    end

    let(:account) { directory_with_verification.accounts.create(account_attrs) }
    let(:verification_emails) do
      application.verification_emails.create(login: account.email)
    end

    after do
      account.delete if account
      directory_with_verification.delete
    end

    it 'returns verification email' do
      expect(verification_emails).to be_kind_of Stormpath::Resource::VerificationEmail
    end
  end

  describe 'create_login_attempt' do
    let(:account) { directory.accounts.create(account_attrs) }

    context 'valid credentials' do
      let(:username_password_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new(
          account.email,
          "P@$$w0rd"
        )
      end

      let(:auth_request) { application.authenticate_account(username_password_request) }

      it 'returns login attempt response' do
        expect(auth_request).to be_kind_of Stormpath::Authentication::AuthenticationResult
      end

      it 'containes account data' do
        expect(auth_request.account.href).to eq(account.href)
      end
    end

    context 'with organization as account store option' do
      let(:organization) do
        test_api_client.organizations.create(name: 'test_organization',
                                             name_key: 'testorganization')
      end

      let(:auth_request) { application.authenticate_account(username_password_request) }

      before do
        map_organization_store(directory, organization)
        map_account_store(application, organization, 0, true, false)
      end

      after do
        organization.delete if organization
      end

      describe 'when sending the proper organization' do
        describe 'using an organization name_key' do
          let(:username_password_request) do
            Stormpath::Authentication::UsernamePasswordRequest.new(
              account.email, "P@$$w0rd",
              account_store: { name_key: organization.name_key }
            )
          end

          it 'returns login attempt response' do
            expect(auth_request).to be_kind_of Stormpath::Authentication::AuthenticationResult
          end

          it 'containes account data' do
            expect(auth_request.account.href).to eq(account.href)
          end
        end

        describe 'using an organization href' do
          let(:username_password_request) do
            Stormpath::Authentication::UsernamePasswordRequest.new(
              account.email, "P@$$w0rd",
              account_store: { href: organization.href }
            )
          end

          it 'returns login attempt response' do
            expect(auth_request).to be_kind_of Stormpath::Authentication::AuthenticationResult
          end

          it 'containes account data' do
            expect(auth_request.account.href).to eq(account.href)
          end
        end

        describe 'using an organization object' do
          let(:username_password_request) do
            Stormpath::Authentication::UsernamePasswordRequest.new(
              account.email, "P@$$w0rd",
              account_store: organization
            )
          end

          it 'returns login attempt response' do
            expect(auth_request).to be_kind_of Stormpath::Authentication::AuthenticationResult
          end

          it 'containes account data' do
            expect(auth_request.account.href).to eq(account.href)
          end
        end
      end

      describe 'when sending the wrong organization' do
        describe 'using an organization name_key' do
          let(:username_password_request) do
            Stormpath::Authentication::UsernamePasswordRequest.new(
              account.email, "P@$$w0rd",
              account_store: { name_key: 'wrong-name-key' }
            )
          end

          it 'raises an error' do
            expect { auth_request }.to raise_error(Stormpath::Error)
          end
        end

        describe 'using an organization href' do
          let(:username_password_request) do
            Stormpath::Authentication::UsernamePasswordRequest.new(
              account.email, "P@$$w0rd",
              account_store: { href: other_organization.href }
            )
          end

          let(:other_organization) do
            test_api_client.organizations.create name: 'other_organization',
               name_key: "other-organization"
          end

          it 'raises an error' do
            expect { auth_request }.to raise_error(Stormpath::Error)
          end
        end

        describe 'using an organization object' do
          let(:username_password_request) do
            Stormpath::Authentication::UsernamePasswordRequest.new(
              account.email, "P@$$w0rd",
              account_store: other_organization
            )
          end

          let(:other_organization) do
            test_api_client.organizations.create name: 'other_organization',
               name_key: "other-organization"
          end

          it 'raises an error' do
            expect { auth_request }.to raise_error(Stormpath::Error)
          end
        end
      end
    end

    context 'with invalid credentials' do
      let(:username_password_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new(
          account.email,
          "invalid"
        )
      end

      let(:auth_request) { application.authenticate_account(username_password_request) }

      it 'returns stormpath error' do
        expect {
          auth_request
        }.to raise_error(Stormpath::Error)
      end
    end
  end

  describe '#verify_password_reset_token' do
    let(:account) { directory.accounts.create(account_attrs) }
    let(:password_reset_token) do
      application.password_reset_tokens.create(email: account.email).token
    end
    let(:reset_password_account) do
      application.verify_password_reset_token password_reset_token
    end

    after do
      account.delete if account
    end

    context 'with decoded password reset token' do
      it 'retrieves the account with the reset password' do
        expect(reset_password_account).to be
        expect(reset_password_account.email).to eq(account.email)
      end
    end

    context 'with encoded password reset token' do
      let(:password_reset_token) do
        URI.encode(application.password_reset_tokens.create(email: account.email).token, '.')
      end
      it 'retrieves the account with the reset password' do
        expect(reset_password_account).to be
        expect(reset_password_account.email).to eq(account.email)
      end
    end

    context 'and if the password is changed' do
      let(:new_password) { 'N3wP@$$w0rd' }

      let(:login_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new account.username, new_password
      end

      let(:authentication_result) do
        application.authenticate_account login_request
      end

      before do
        reset_password_account.password = new_password
        reset_password_account.save
      end

      it 'can be successfully authenticated' do
        expect(authentication_result).to be
        expect(authentication_result.account).to be
        expect(authentication_result.account).to be_kind_of Stormpath::Resource::Account
        expect(authentication_result.account.email).to eq(account.email)
      end
    end
  end

  describe '#create_application_with_custom_data' do
    it 'creates an application with custom data' do
      application.custom_data["category"] = "classified"
      application.save

      expect(application.custom_data["category"]).to eq("classified")
    end
  end

  describe '#create_id_site_url' do
    let(:jwt_token) { JWT.encode({
        'iat' => Time.now.to_i,
        'jti' => UUID.method(:random_create).call.to_s,
        'aud' => test_api_key_id,
        'sub' => application.href,
        'cb_uri' => 'http://localhost:9292/redirect',
        'path' => '',
        'state' => ''
      }, test_api_key_secret, 'HS256')
    }

    let(:create_id_site_url_result) do
      options = { callback_uri: 'http://localhost:9292/redirect' }
      application.create_id_site_url options
    end

    it 'should create a url with jwtRequest' do
      expect(create_id_site_url_result).to include('jwtRequest')
    end

    it 'should create a request to /sso' do
      expect(create_id_site_url_result).to include('/sso')
    end

    it 'should create a jwtRequest that is signed wit the client secret' do
      uri = Addressable::URI.parse(create_id_site_url_result)
      jwt_token = JWT.decode(uri.query_values["jwtRequest"], test_api_key_secret).first

      expect(jwt_token["iss"]).to eq test_api_key_id
      expect(jwt_token["sub"]).to eq application.href
      expect(jwt_token["cb_uri"]).to eq 'http://localhost:9292/redirect'
    end

    context 'with logout option' do
      it 'shoud create a request to /sso/logout' do
      end
    end

    context 'without providing cb_uri' do
      let(:create_id_site_url_result) do
        options = { callback_uri: '' }
        application.create_id_site_url options
      end

      it 'should raise Stormpath Error with correct id_site error data' do
        begin
          create_id_site_url_result
        rescue Stormpath::Error => error
          expect(error.status).to eq(400)
          expect(error.code).to eq(400)
          expect(error.message).to eq("The specified callback URI (cb_uri) is not valid")
          expect(error.developer_message).to eq("The specified callback URI (cb_uri) is not valid. Make sure the "\
            "callback URI specified in your ID Site configuration matches the value specified.")
        end
      end
    end
  end

  describe '#handle_id_site_callback' do
    let(:callback_uri_base) { 'http://localhost:9292/somwhere?jwtResponse=' }

    context 'without the response_url provided' do
      it 'should raise argument error' do
        expect { application.handle_id_site_callback(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'with a valid jwt response' do
      let(:jwt_token) { JWT.encode({
          'iat' => Time.now.to_i,
          'aud' => test_api_key_id,
          'sub' => application.href,
          'path' => '',
          'state' => '',
          'isNewSub' => true,
          'status' => "REGISTERED"
        }, test_api_key_secret, 'HS256')
      }

      before do
        @site_result = application.handle_id_site_callback(callback_uri_base + jwt_token)
      end

      it 'should return IdSiteResult object' do
        expect(@site_result).to be_kind_of(Stormpath::IdSite::IdSiteResult)
      end

      it 'should set the correct account on IdSiteResult object' do
        expect(@site_result.account_href).to eq(application.href)
      end

      it 'should set the correct status on IdSiteResult object' do
        expect(@site_result.status).to eq("REGISTERED")
      end

      it 'should set the correct state on IdSiteResult object' do
        expect(@site_result.state).to eq("")
      end

      it 'should set the correct is_new_account on IdSiteResult object' do
        expect(@site_result.new_account?).to eq(true)
      end
    end

    context 'with an expired token' do
      let(:jwt_token) { JWT.encode({
          'iat' => Time.now.to_i,
          'aud' => test_api_key_id,
          'sub' => application.href,
          'path' => '',
          'state' => '',
          'exp' => Time.now.to_i - 1,
          'isNewSub' => true,
          'status' => "REGISTERED"
        }, test_api_key_secret, 'HS256')
      }

      it 'should raise Stormpath Error with correct data' do
        begin
          application.handle_id_site_callback(callback_uri_base + jwt_token)
        rescue Stormpath::Error => error
          expect(error.status).to eq(400)
          expect(error.code).to eq(10011)
          expect(error.message).to eq("Token is invalid")
          expect(error.developer_message).to eq("Token is no longer valid because it has expired")
        end
      end

      it 'should raise expiration error' do
        expect {
          application.handle_id_site_callback(callback_uri_base + jwt_token)
        }.to raise_error(Stormpath::Error)
      end
    end

    context 'with a different client id (aud)' do
      let(:jwt_token) { JWT.encode({
          'iat' => Time.now.to_i,
          'aud' => UUID.method(:random_create).call.to_s,
          'sub' => application.href,
          'path' => '',
          'state' => '',
          'isNewSub' => true,
          'status' => "REGISTERED"
        }, test_api_key_secret, 'HS256')
      }

      it 'should raise error' do
        expect {
          application.handle_id_site_callback(callback_uri_base + jwt_token)
        }.to raise_error(Stormpath::Error)
      end

      it 'should raise Stormpath Error with correct id_site error data' do
        begin
          application.handle_id_site_callback(callback_uri_base + jwt_token)
        rescue Stormpath::Error => error
          expect(error.status).to eq(400)
          expect(error.code).to eq(10012)
          expect(error.message).to eq("Token is invalid")
          expect(error.developer_message).to eq("Token is invalid because the issued at time (iat) "\
            "is after the current time")
        end
      end
    end

    context 'with an invalid exp value' do
      let(:jwt_token) { JWT.encode({
          'iat' => Time.now.to_i,
          'aud' => test_api_key_id,
          'sub' => application.href,
          'path' => '',
          'state' => '',
          'exp' => 'not gona work',
          'isNewSub' => true,
          'status' => "REGISTERED"
        }, test_api_key_secret, 'HS256')
      }

      it 'should error with the stormpath error' do
        expect {
          application.handle_id_site_callback(callback_uri_base + jwt_token)
        }.to raise_error(Stormpath::Error)
      end
    end

    context 'with an invalid signature' do
      let(:jwt_token) { JWT.encode({
          'iat' => Time.now.to_i,
          'aud' => test_api_key_id,
          'sub' => application.href,
          'path' => '',
          'state' => '',
          'isNewSub' => true,
          'status' => "REGISTERED"
        }, 'false key', 'HS256')
      }

      it 'should reject the signature' do
        expect {
          application.handle_id_site_callback(callback_uri_base + jwt_token)
        }.to raise_error(JWT::DecodeError)
      end
    end

    context 'with show_organization_field key specified' do
      let(:jwt_token) { JWT.encode({
          'iat' => Time.now.to_i,
          'aud' => test_api_key_id,
          'sub' => application.href,
          'path' => '',
          'state' => '',
          'isNewSub' => true,
          'status' => "REGISTERED",
          'organization_name_key' => 'stormtroopers',
          'usd' => true,
          'sof' => true
        }, test_api_key_secret, 'HS256')
      }

      before do
        @site_result = application.handle_id_site_callback(callback_uri_base + jwt_token)
      end

      it 'should return IdSiteResult object' do
        expect(@site_result).to be_kind_of(Stormpath::IdSite::IdSiteResult)
      end
    end
  end

  describe '#authenticate_oauth' do
    let(:account_data) { account_attrs }
    let(:password_grant_request) { Stormpath::Oauth::PasswordGrantRequest.new account_data[:email], account_data[:password] }
    let(:aquire_token) { application.authenticate_oauth(password_grant_request) }
    let(:account) { application.accounts.create account_data }

    before { account }

    context 'generate access token from password grant request' do
      let(:password_grant_request) { Stormpath::Oauth::PasswordGrantRequest.new account_data[:email], account_data[:password] }
      let(:authenticate_oauth) { application.authenticate_oauth(password_grant_request) }

      context 'without organization_name_key' do
        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end
      end

      context 'with the organization name key' do
        let!(:organization) do
          test_api_client.organizations.create name: 'rspec-test-org', name_key: 'rspec-test-org'
        end
        let(:account_directory) do
          test_api_client.directories.create(
            name: 'rspec-directory'
          )
        end
        let(:reloaded_account_directory) do
          test_api_client.directories.get(account_directory.href)
        end
        let(:password_grant_request) do
          Stormpath::Oauth::PasswordGrantRequest.new(account_data[:email],
                                                     account_data[:password],
                                                     organization_name_key: 'rspec-test-org')
        end

        after do
          organization.delete
          reloaded_account_directory.delete
        end

        before do
          map_account_store(application, organization, 0, true, true)
          map_organization_store(account_directory, organization)
          account_directory.accounts.create account_data
        end

        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end

        it 'access and refresh token should contain org in payload' do
          jw_access = JWT.decode(authenticate_oauth.access_token, test_api_client.data_store.api_key.secret)
          jw_refresh = JWT.decode(authenticate_oauth.refresh_token, test_api_client.data_store.api_key.secret)
          expect(jw_access.first).to include('org')
          expect(jw_refresh.first).to include('org')
        end
      end
    end

    context 'generate access token from stormpath_token grant request' do
      context 'where status authenticated' do
        let(:stormpath_grant_request) do
          Stormpath::Oauth::StormpathGrantRequest.new(
            account,
            application,
            test_api_client.data_store.api_key
          )
        end

        let(:authenticate_oauth) { application.authenticate_oauth(stormpath_grant_request) }

        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end
      end

      context 'where status registered' do
        let(:stormpath_grant_request) do
          Stormpath::Oauth::StormpathGrantRequest.new(
            account,
            application,
            test_api_client.data_store.api_key,
            :registered
          )
        end

        let(:authenticate_oauth) { application.authenticate_oauth(stormpath_grant_request) }

        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end
      end
    end

    context 'generate access token from client credentials request' do
      let(:account_api_key) { account.api_keys.create({}) }

      let(:client_credentials_grant_request) do
        Stormpath::Oauth::ClientCredentialsGrantRequest.new(
          account_api_key.id,
          account_api_key.secret
        )
      end

      let(:authenticate_oauth) { application.authenticate_oauth(client_credentials_grant_request) }

      it 'should return access token response' do
        expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
      end

      it 'response should contain token data' do
        expect(authenticate_oauth.access_token).not_to be_empty
        expect(authenticate_oauth.token_type).not_to be_empty
        expect(authenticate_oauth.expires_in).not_to be_nil
        expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
      end
    end

    context 'generate access token from stormpath_social grant request' do
      let(:authenticate_oauth) { application.authenticate_oauth(social_grant_request) }

      context 'google' do
        let(:code) { '4/WByqYc1UOvcYluBOsFyFbm8_BIZHbjklC5iEz7AdXcA' }
        let(:social_grant_request) do
          Stormpath::Oauth::SocialGrantRequest.new(:google, code: code)
        end
        before do
          stub_request(:post,
          "https://#{test_api_key_id}:#{test_api_key_secret}@api.stormpath.com/v1/applications/#{application.href.split('/').last}/oauth/token")
          .to_return(body: Stormpath::Test.mocked_social_grant_response)
        end

        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end
      end

      context 'linkedin' do
        let(:code) { '4/WByqYc1UOvcYluBOsFyFbm8_BIZHbjklC5iEz7AdXcA' }
        let(:social_grant_request) do
          Stormpath::Oauth::SocialGrantRequest.new(:linkedin, code: code)
        end
        before do
          stub_request(:post,
          "https://#{test_api_key_id}:#{test_api_key_secret}@api.stormpath.com/v1/applications/#{application.href.split('/').last}/oauth/token")
          .to_return(body: Stormpath::Test.mocked_social_grant_response)
        end

        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end
      end

      context 'facebook' do
        let(:access_token) { '4/WByqYc1UOvcYluBOsFyFbm8_BIZHbjklC5iEz7AdXcA' }
        let(:social_grant_request) do
          Stormpath::Oauth::SocialGrantRequest.new(:google, access_token: access_token)
        end
        before do
          stub_request(:post,
          "https://#{test_api_key_id}:#{test_api_key_secret}@api.stormpath.com/v1/applications/#{application.href.split('/').last}/oauth/token")
          .to_return(body: Stormpath::Test.mocked_social_grant_response)
        end

        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end
      end

      context 'github' do
        let(:access_token) { '4/WByqYc1UOvcYluBOsFyFbm8_BIZHbjklC5iEz7AdXcA' }
        let(:social_grant_request) do
          Stormpath::Oauth::SocialGrantRequest.new(:github, access_token: access_token)
        end
        before do
          stub_request(:post,
          "https://#{test_api_key_id}:#{test_api_key_secret}@api.stormpath.com/v1/applications/#{application.href.split('/').last}/oauth/token")
          .to_return(body: Stormpath::Test.mocked_social_grant_response)
        end

        it 'should return access token response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
        end

        it 'response should contain token data' do
          expect(authenticate_oauth.access_token).not_to be_empty
          expect(authenticate_oauth.refresh_token).not_to be_empty
          expect(authenticate_oauth.token_type).not_to be_empty
          expect(authenticate_oauth.expires_in).not_to be_nil
          expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
        end
      end
    end

    context 'generate access token from challenge factor grant request' do
      before do
        stub_request(:post,
                     "https://#{test_api_key_id}:#{test_api_key_secret}@#{test_host}/v1/accounts/#{account.href.split('/').last}/factors?challenge=true")
          .to_return(body: Stormpath::Test.mocked_factor_response)

        stub_request(:post,
                     "https://#{test_api_key_id}:#{test_api_key_secret}@#{test_host}/v1/applications/#{application.href.split('/').last}/oauth/token")
          .to_return(body: Stormpath::Test.mocked_challenge_factor_grant_response)
      end
      let(:account_data) { account_attrs }
      let(:authenticate_oauth) { application.authenticate_oauth(challenge_factor_grant_request) }
      let(:challenge_factor_grant_request) do
        Stormpath::Oauth::ChallengeFactorGrantRequest.new(challenge, code)
      end
      let(:account) do
        application.accounts.create(account_data)
      end
      let(:factor) do
        account.create_factor(:sms,
                              phone: { number: '+12025550173',
                                       name: 'Rspec test phone',
                                       description: 'This is a testing phone number' },
                              challenge: { message: 'Enter code please: ' })
      end
      let(:challenge) { "https://#{test_host}/v1/challenges/29300284904" }
      let(:code) { '123456' }

      it 'should return access token response' do
        expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
      end

      it 'response should contain token data' do
        expect(authenticate_oauth.access_token).not_to be_empty
        expect(authenticate_oauth.refresh_token).not_to be_empty
        expect(authenticate_oauth.token_type).not_to be_empty
        expect(authenticate_oauth.expires_in).not_to be_nil
        expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
      end
    end

    context 'exchange id site token for access_token with invalid jwt' do
      let(:invalid_jwt_token) { 'invalid_token' }

      let(:id_site_grant_request) { Stormpath::Oauth::IdSiteGrantRequest.new invalid_jwt_token }
      let(:authenticate_oauth) { application.authenticate_oauth(id_site_grant_request) }

      it 'should raise invalid token error' do
        expect {
          authenticate_oauth
        }.to raise_error(Stormpath::Error)
      end
    end

    context 'echange id site token for access_token with valid jwt' do
      let(:jwt_token) { JWT.encode({
          'iat' => Time.now.to_i,
          'jti' => UUID.method(:random_create).call.to_s,
          'iss' => test_api_client.data_store.api_key.id,
          'sub' => application.href,
          'cb_uri' => 'http://localhost:9292/redirect',
          'path' => '',
          'state' => ''
        }, test_api_client.data_store.api_key.secret, 'HS256')
      }

      it 'should create a jwtRequest that is signed wit the client secret' do
        allow(application.client.data_store).to receive(:create).and_return(Stormpath::Oauth::AccessTokenAuthenticationResult)
        expect(application.client.data_store).to receive(:instantiate)
          .with(Stormpath::Oauth::IdSiteGrant)
          .and_return(Stormpath::Oauth::IdSiteGrant.new({}, application.client))

        grant_request = Stormpath::Oauth::IdSiteGrantRequest.new jwt_token
        response = application.authenticate_oauth(grant_request)

        expect(response).to be(Stormpath::Oauth::AccessTokenAuthenticationResult)
      end
    end

    context 'refresh token' do
      let(:refresh_grant_request) { Stormpath::Oauth::RefreshGrantRequest.new aquire_token.refresh_token }
      let(:authenticate_oauth) { application.authenticate_oauth(refresh_grant_request) }

      it 'should return access token response with refreshed token' do
        expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::AccessTokenAuthenticationResult)
      end

      it 'refreshed token is not the same as previous one' do
        expect(authenticate_oauth.access_token).not_to be_equal(aquire_token.access_token)
      end

      it 'returns success with data' do
        expect(authenticate_oauth.access_token).not_to be_empty
        expect(authenticate_oauth.refresh_token).not_to be_empty
        expect(authenticate_oauth.token_type).not_to be_empty
        expect(authenticate_oauth.expires_in).not_to be_nil
        expect(authenticate_oauth.stormpath_access_token_href).not_to be_empty
      end
    end

    context 'validate access token' do
      context 'remotely' do
        let(:access_token) { aquire_token.access_token }
        let(:authenticate_oauth) do
          Stormpath::Oauth::VerifyAccessToken.new(application).verify(access_token)
        end

        it 'should return authentication result response' do
          expect(authenticate_oauth).to be_kind_of(Stormpath::Oauth::VerifyTokenResult)
        end

        it 'returns success on valid token' do
          expect(authenticate_oauth.href).not_to be_empty
          expect(authenticate_oauth.account).to be_a(Stormpath::Resource::Account)
          expect(authenticate_oauth.account).to eq(account)
          expect(authenticate_oauth.application).to be_a(Stormpath::Resource::Application)
          expect(authenticate_oauth.application).to eq(application)
          expect(authenticate_oauth.jwt).not_to be_empty
          expect(authenticate_oauth.tenant).to be_a(Stormpath::Resource::Tenant)
          expect(authenticate_oauth.tenant).to eq(test_api_client.tenant)
          expect(authenticate_oauth.expanded_jwt).not_to be_empty
        end
      end

      context 'locally' do
        let(:access_token) { aquire_token.access_token }
        let(:authenticate_oauth) do
          Stormpath::Oauth::VerifyAccessToken.new(application, local: true).verify(access_token)
        end

        it 'should return local access token verification result' do
          expect(authenticate_oauth)
            .to be_kind_of(Stormpath::Oauth::LocalAccessTokenVerificationResult)
        end

        it 'should return result that contains account' do
          expect(authenticate_oauth.account).to eq(account)
        end
      end
    end

    context 'delete token' do
      it 'after token was deleted user can authenticate with the same token' do
        access_token = aquire_token.access_token
        aquire_token.delete

        expect {
          Stormpath::Oauth::VerifyAccessToken.new(application).verify(access_token)
        }.to raise_error(Stormpath::Error)
      end
    end
  end
end
