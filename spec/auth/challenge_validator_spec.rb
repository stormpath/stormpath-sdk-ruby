require 'spec_helper'

describe Stormpath::Authentication::ChallengeValidator, vcr: true do
  let(:data_store) { test_api_client.data_store }
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  before { map_account_store(application, directory, 0, true, true) }
  let(:account) { directory.accounts.create(account_attrs) }
  let(:code) { '1234567' }
  let(:validate_challenge) do
    Stormpath::Authentication::ChallengeValidator.new(data_store, challenge.href).validate(code)
  end

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
  let(:challenge) { factor.challenges.create(message: 'Enter code: ${code}') }

  after do
    application.delete
    directory.delete
  end

  describe 'valid code' do
    before do
      stub_request(:post, "#{factor.href}/challenges")
        .to_return(body: Stormpath::Test.mocked_successfull_challenge)
      stub_request(:post, challenge.href)
        .to_return(body: Stormpath::Test.mocked_successfull_challenge)
    end

    it 'should respond with a Challenge' do
      expect(validate_challenge).to be_a Stormpath::Resource::Challenge
      expect(validate_challenge.status).to eq 'SUCCESS'
    end

    it 'should have status SUCCESS' do
      expect(validate_challenge.status).to eq 'SUCCESS'
    end
  end

  describe 'invalid code' do
    before do
      stub_request(:post, "#{factor.href}/challenges")
        .to_return(body: Stormpath::Test.mocked_failed_challenge)
      stub_request(:post, challenge.href)
        .to_return(body: Stormpath::Test.mocked_failed_challenge)
    end

    it 'should respond with a Challenge' do
      expect(validate_challenge).to be_a Stormpath::Resource::Challenge
    end

    it 'should have status FAILED' do
      expect(validate_challenge.status).to eq 'FAILED'
    end
  end
end
