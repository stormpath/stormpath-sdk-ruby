require 'spec_helper'

describe 'CreateFactor', vcr: true do
  let(:client) { test_api_client }
  let(:directory) { client.directories.create(build_directory) }
  let(:account) { directory.accounts.create(build_account) }

  context 'with challenge' do
    let(:factor) do
      Stormpath::Authentication::CreateFactor.new(
        client,
        account,
        'SMS',
        phone: { number: '+12025550173',
                 name: 'Rspec test phone',
                 description: 'This is a testing phone number' },
        challenge: { message: 'Enter code please: ' }
      ).save
    end

    it 'should create factor and challenge' do
      expect(factor.href).to be
      expect(factor.challenges.count).to eq 1
    end
  end

  context 'without challenge' do
    let(:factor) do
      Stormpath::Authentication::CreateFactor.new(
        client,
        account,
        'SMS',
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

  after do
    sleep 5
    directory.delete
  end
end
