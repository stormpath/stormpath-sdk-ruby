require 'spec_helper'

describe Stormpath::Resource::Schema, :vcr do
  let(:application) { test_api_client.applications.create(build_application) }
  let(:directory) { test_api_client.directories.create(build_directory) }
  let(:schema) { directory.account_schema }

  after do
    directory.delete
    application.delete
  end

  describe 'instances should respond to attribute property methods' do
    it do
      expect(schema).to be_a Stormpath::Resource::Schema

      [:created_at, :modified_at].each do |property_getter|
        expect(schema).to respond_to(property_getter)
        expect(schema.send(property_getter)).to be_a String
      end
    end
  end

  describe 'schema associations' do
    context '#fields' do
      let(:field) { directory.fields.first }

      it 'should be able to get a list of fields' do
        expect(schema.fields).to be_a Stormpath::Resource::Collection
      end
    end

    context '#directory' do
      it 'should be able to fetch the directory' do
        expect(schema.directory).to eq directory
      end
    end
  end
end
