require 'spec_helper'

describe Stormpath::Resource::Challenge, :vcr do
  describe 'instances should respond to attribute property methods' do
    let(:directory) { test_api_client.directories.create(build_directory) }
    let(:account) { directory.accounts.create(build_account) }

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

    before do
      stub_request(:post, "#{factor.href}/challenges")
        .to_return(body: Stormpath::Test.mocked_challenge)
    end

    let(:challenge) { factor.challenges.create(message: 'Enter code: ${code}') }

    after { directory.delete }

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
end
