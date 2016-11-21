require 'spec_helper'

describe Stormpath::Resource::Field, :vcr do
  let(:application) { test_api_client.applications.create(build_application) }
  let(:directory) { test_api_client.directories.create(build_directory) }
  let(:account_schema) { directory.account_schema }
  let(:field) { account_schema.fields.first }

  after do
    directory.delete
    application.delete
  end

  describe 'instances should respond to attribute property methods' do
    it do
      expect(field).to be_a Stormpath::Resource::Field

      [:name, :created_at, :modified_at].each do |property_getter|
        expect(field).to respond_to(property_getter)
        expect(field.send(property_getter)).to be_a String
      end

      expect(field).to respond_to(:required)
      expect(field.required).to eq !!field.required
    end
  end

  describe 'field associations' do
    context '#schema' do
      it 'should be able to get the account schema' do
        expect(field.schema).to be_a Stormpath::Resource::Schema
      end
    end
  end
end
