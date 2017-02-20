require 'spec_helper'

describe Stormpath::Resource::Challenge, :vcr do
  let(:directory) { test_api_client.directories.create(directory_attrs) }
  let(:account) { directory.accounts.create(account_attrs) }
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
  let(:validate_challenge) { challenge.validate('123456') }

  before do
    stub_request(:post, "#{factor.href}/challenges")
      .to_return(body: Stormpath::Test.mocked_challenge)

    stub_request(:post, challenge.href)
      .to_return(body: Stormpath::Test.mocked_successfull_challenge)
  end

  after { directory.delete }

  describe 'instances should respond to attribute property methods' do
    it do
      [:message].each do |property_accessor|
        expect(challenge).to respond_to(property_accessor)
        expect(challenge).to respond_to("#{property_accessor}=")
        expect(challenge.send(property_accessor)).to be_a String
      end

      [:status, :created_at, :modified_at].each do |property_getter|
        expect(challenge).to respond_to(property_getter)
        expect(challenge.send(property_getter)).to be_a String
      end

      expect(challenge.factor).to be_a Stormpath::Resource::Factor
      expect(challenge.account).to be_a Stormpath::Resource::Account
    end
  end

  describe '#validate' do
    it 'should return successfull challenge for valid code from sms' do
      expect(validate_challenge.status).to eq 'SUCCESS'
    end
  end
end
