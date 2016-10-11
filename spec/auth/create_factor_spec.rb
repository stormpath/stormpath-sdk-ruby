require 'spec_helper'

describe 'CreateFactor', vcr: true do
  let(:client) { test_api_client }
  let(:directory) { client.directories.create name: random_directory_name }
  let(:account) do
    directory.accounts.create(email: 'test@example.com',
                              given_name: 'Ruby SDK',
                              password: 'P@$$w0rd',
                              surname: 'SDK',
                              username: 'rubysdk')
  end

  context 'with challenge' do
    let(:factor) do
      Stormpath::Authentication::CreateFactor.new(
        client,
        account,
        'SMS',
        phone: { number: '+385958142457',
                 name: 'Rspec test phone',
                 description: 'This is a testing phone number' },
        challenge: { message: 'Enter code please: ' }
      ).save
    end

    it 'should create factor' do
      expect(factor.href).to be
    end

    it 'should create challenge' do
      expect(factor.challenges.count).to be 1
    end

    after { factor.delete }
  end

  context 'without challenge' do
    let(:factor) do
      Stormpath::Authentication::CreateFactor.new(
        client,
        account,
        'SMS',
        phone: { number: '+385958142457',
                 name: 'Rspec test phone',
                 description: 'This is a testing phone number' }
      ).save
    end

    it 'should create factor' do
      expect(factor.href).to be
    end

    it 'should not create challenge' do
      expect(factor.challenges.count).to be 0
    end

    after { factor.delete }
  end

  after do
    account.delete if account
    directory.delete if directory
  end
end
