require 'spec_helper'

describe Stormpath::Resource::AccountSchema, :vcr do
  let(:application) { test_api_client.applications.create(build_application) }
  let(:directory) { test_api_client.directories.create(build_directory) }
  let(:account_schema) { directory.account_schema }

  after do
    directory.delete
    application.delete
  end

  describe 'instances should respond to attribute property methods' do
    it do
      expect(account_schema).to be_a Stormpath::Resource::AccountSchema

      [:created_at, :modified_at].each do |property_getter|
        expect(account_schema).to respond_to(property_getter)
        expect(account_schema.send(property_getter)).to be_a String
      end
    end
  end

  describe 'account_schema associations' do
    context '#fields' do
      let(:field) { directory.fields.first }

      it 'should be able to get a list of fields' do
        expect(account_schema.fields).to be_a Stormpath::Resource::Collection
      end
    end
  end
end
