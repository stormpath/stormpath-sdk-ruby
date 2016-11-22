require 'spec_helper'

describe Stormpath::Resource::Factor, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create(directory_attrs) }
    let(:account) { directory.accounts.create(account_attrs) }

    after do
      factor.delete if factor
      account.delete if account
      directory.delete if directory
    end

    context 'type sms' do
      let(:factor) do
        account.factors.create(
          type: 'SMS',
          phone: {
            number: '+12025550173',
            name: 'test phone',
            description: 'this is a testing phone number'
          }
        )
      end

      it do
        [:type, :status].each do |property_accessor|
          expect(factor).to respond_to(property_accessor)
          expect(factor).to respond_to("#{property_accessor}=")
          expect(factor.send(property_accessor)).to be_a String
        end

        [:verification_status].each do |property_getter|
          expect(factor).to respond_to(property_getter)
          expect(factor.send(property_getter)).to be_a String
        end

        expect(factor.account).to be_a Stormpath::Resource::Account
        expect(factor.phone).to be_a Stormpath::Resource::Phone
        expect(factor.challenges).to be_a Stormpath::Resource::Collection
      end
    end

    context 'type google_authenticator' do
      let(:factor) do
        account.factors.create(
          type: 'google-authenticator',
          issuer: 'ACME'
        )
      end

      it do
        [:type, :status].each do |property_accessor|
          expect(factor).to respond_to(property_accessor)
          expect(factor).to respond_to("#{property_accessor}=")
          expect(factor.send(property_accessor)).to be_a String
        end

        [:verification_status, :secret, :key_uri, :base64_q_r_image, :qr_code].each do |property_getter|
          expect(factor).to respond_to(property_getter)
          expect(factor.send(property_getter)).to be_a String
        end

        expect(factor.account).to be_a Stormpath::Resource::Account
      end
    end
  end

  describe 'factor associations' do
    let(:app) { test_api_client.applications.create(application_attrs) }
    let(:application) { test_api_client.applications.get app.href }
    let(:directory) { test_api_client.directories.create(directory_attrs) }

    before { map_account_store(app, directory, 1, true, true) }
    let(:account) { directory.accounts.create(account_attrs) }
    let(:phone_number) { '+12025550173' }

    let(:factor) do
      account.factors.create(
        type: 'SMS',
        phone: {
          number: phone_number,
          name: 'test phone',
          description: 'this is a testing phone number'
        }
      )
    end

    it 'should belong_to account' do
      expect(factor.account).to eq(account)
    end

    it 'should have one phone' do
      expect(factor.phone.number).to eq(phone_number)
    end

    context 'challenges' do
      before do
        stub_request(:post, "#{factor.href}/challenges")
          .to_return(body: Stormpath::Test.mocked_challenge)
        stub_request(:get, factor.href)
          .to_return(body: Stormpath::Test.mocked_factor_response)
      end
      let!(:challenge) { factor.challenges.create(message: 'Enter code: ${code}') }

      it 'should have a collection of challenges' do
        expect(factor.challenges).to be_a Stormpath::Resource::Collection
      end

      it 'should have the most recent challenge' do
        most_recent_challenge = factor.challenges.create(message: 'Enter new code: ${code}')
        reloaded_factor = account.factors.get(factor.href)
        expect(reloaded_factor.most_recent_challenge.href).to eq(most_recent_challenge.href)
      end
    end

    after do
      application.delete if application
      account.delete if account
      directory.delete if directory
      factor.delete if factor
    end
  end
end
