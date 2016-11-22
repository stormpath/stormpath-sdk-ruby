require 'spec_helper'

describe 'CreateFactor', vcr: true do
  let(:client) { test_api_client }
  let(:directory) { client.directories.create(directory_attrs) }
  let(:account) { directory.accounts.create(account_attrs) }

  after { directory.delete }

  context 'type sms' do
    context 'with challenge' do
      before do
        stub_request(:post, "#{account.href}/factors?challenge=true")
          .to_return(body: Stormpath::Test.mocked_factor_response)
        stub_request(:get, "#{factor.href}/challenges")
          .to_return(body: Stormpath::Test.mocked_challenges_response)
        stub_request(:get, "#{factor.href}/challenges?offset=25")
          .to_return(body: Stormpath::Test.mocked_challenges_response)
      end
      let(:factor) do
        Stormpath::Authentication::CreateFactor.new(
          client,
          account,
          :sms,
          phone: { number: '+12025550173',
                   name: 'Rspec test phone',
                   description: 'This is a testing phone number' },
          challenge: { message: 'Enter code please: ' }
        ).save
      end

      it 'should create factor' do
        expect(factor.href).to be
      end
    end

    context 'without challenge' do
      before do
        stub_request(:post, "#{account.href}/factors")
          .to_return(body: Stormpath::Test.mocked_factor_response)
        stub_request(:get, "#{factor.href}/challenges")
          .to_return(body: Stormpath::Test.mocked_empty_challenge_response)
        stub_request(:get, "#{factor.href}/challenges?offset=25")
          .to_return(body: Stormpath::Test.mocked_empty_challenge_response)
      end
      let(:factor) do
        Stormpath::Authentication::CreateFactor.new(
          client,
          account,
          :sms,
          phone: { number: '+12025550173',
                   name: 'Rspec test phone',
                   description: 'This is a testing phone number' }
        ).save
      end

      it 'should create factor without challenge' do
        expect(factor.href).to be
        expect(factor.challenges.count).to eq 0
      end
    end
  end

  context 'type google-authenticator' do
    let(:factor) do
      Stormpath::Authentication::CreateFactor.new(
        client,
        account,
        :google_authenticator,
        custom_options: {
          account_name: "marko.cilimkovic#{default_domain}",
          issuer: 'ACME',
          status: 'ENABLED'
        }
      ).save
    end

    it 'should create factor' do
      expect(factor.href).to be
    end
  end

  context 'bad type' do
    let(:factor) do
      Stormpath::Authentication::CreateFactor.new(client, account, :invalid_factor_type).save
    end

    it 'should raise error' do
      expect { factor }.to raise_error(Stormpath::Error)
    end
  end
end
