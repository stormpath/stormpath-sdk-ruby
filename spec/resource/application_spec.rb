require 'spec_helper'

describe Stormpath::Resource::Application, :vcr do
  let(:application) { test_application }
  let(:directory) { test_directory }

  describe '.load' do
    let(:url) do
      uri = URI(application.href)
      credentialed_uri = URI::HTTPS.new(
        uri.scheme, "#{test_api_key_id}:#{test_api_key_secret}", uri.host,
        uri.port, uri.registry, uri.path, uri.query, uri.opaque, uri.fragment
      )
      credentialed_uri.to_s
    end

    it "raises a LoadError with an invalid url" do
      expect {
        Stormpath::Resource::Application.load 'this is an invalid url'
      }.to raise_error(Stormpath::Resource::Application::LoadError)
    end

    it "instantiates client and application objects from a composite URL" do
      loaded_application = Stormpath::Resource::Application.load(url)
      expect(loaded_application).to eq(application)
    end
  end

  describe '#authenticate_account' do
    let(:account) do
      directory.accounts.create build_account(password: 'P@$$w0rd')
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

    let(:login_request) do
      Stormpath::Authentication::UsernamePasswordRequest.new account.username, password
    end

    let(:new_directory) { test_api_client.directories.create name: 'test_account_store'}

    let(:authentication_result) { application.authenticate_account login_request, new_directory}

    before do
      test_api_client.account_store_mappings.create({ application: application, account_store: new_directory })
    end

    after do
      account.delete if account
      new_directory.delete if new_directory
    end
    
    context 'given a proper directory' do 
      let(:account) { new_directory.accounts.create build_account(password: 'P@$$w0rd') }

      it 'should return an authentication result' do
        expect(authentication_result).to be
        expect(authentication_result.account).to be
        expect(authentication_result.account).to be_kind_of Stormpath::Resource::Account
        expect(authentication_result.account.email).to eq(account.email)
      end
    end

    context 'given a wrong directory' do
      let(:account) { directory.accounts.create build_account(password: 'P@$$w0rd') }

      it 'raises and error' do
        expect { authentication_result }.to raise_error Stormpath::Error
      end
    end

  end

  describe '#send_password_reset_email' do
    context 'given an email' do
      context 'of an exisiting account on the application' do
        let(:account) { directory.accounts.create build_account  }

        let(:sent_to_account) { application.send_password_reset_email account.email }

        after do
          account.delete if account
        end

        it 'sends a password reset request of the account' do
          expect(sent_to_account).to be
          expect(sent_to_account).to be_kind_of Stormpath::Resource::Account
          expect(sent_to_account.email).to eq(account.email)
        end
      end

      context 'of a non exisitng account' do
        it 'raises an exception' do
          expect do
            application.send_password_reset_email "test@example.com"
          end.to raise_error Stormpath::Error
        end
      end
    end
  end

  describe '#verify_password_reset_token' do
    let(:account) do
      directory.accounts.create({
        email: 'test@example.com',
        given_name: 'Ruby SDK',
        password: 'P@$$w0rd',
        surname: 'SDK',
        username: 'rubysdk'
      })
    end

    let(:password_reset_token) do
      application.password_reset_tokens.create(email: account.email).token
    end

    let(:reset_password_account) do
      application.verify_password_reset_token password_reset_token
    end

    after do
      account.delete if account
    end

    it 'retrieves the account with the reset password' do
      expect(reset_password_account).to be
      expect(reset_password_account.email).to eq(account.email)
    end

    context 'and if the password is changed' do
      let(:new_password) { 'N3wP@$$w0rd' }

      let(:login_request) do
        Stormpath::Authentication::UsernamePasswordRequest.new account.username, new_password
      end

      let(:expected_email) { 'test2@example.com' }

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
end
