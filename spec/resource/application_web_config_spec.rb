require 'spec_helper'

describe Stormpath::Resource::ApplicationWebConfig, :vcr do
  let(:application) { test_api_client.applications.create(application_attrs) }
  let(:web_config) { application.web_config }
  after { application.delete }

  describe 'instances should respond to attribute property methods' do
    it do
      expect(web_config).to be_a Stormpath::Resource::ApplicationWebConfig

      [:dns_label, :status].each do |property_accessor|
        expect(web_config).to respond_to(property_accessor)
        expect(web_config).to respond_to("#{property_accessor}=")
        expect(web_config.send(property_accessor)).to be_a String
      end

      [:domain_name, :created_at, :modified_at].each do |property_getter|
        expect(web_config).to respond_to(property_getter)
        expect(web_config.send(property_getter)).to be_a String
      end

      expect(web_config.tenant).to be_a Stormpath::Resource::Tenant
      expect(web_config.application).to be_a Stormpath::Resource::Application
      expect(web_config.signing_api_key).to be_a Stormpath::Resource::ApiKey
    end

    it 'should respond to endpoints' do
      Stormpath::Resource::ApplicationWebConfig::ENDPOINTS.each do |endpoint|
        expect(web_config).to respond_to(endpoint)
        expect(web_config).to respond_to("#{endpoint}=")
        expect(web_config.send(endpoint)).to be_a Hash
      end
    end
  end

  describe 'enabling/disabling endpoints' do
    it 'should be able to switch to enabled and disabled' do
      Stormpath::Resource::ApplicationWebConfig::ENDPOINTS.each do |endpoint|
        instance_eval("web_config.#{endpoint}= { enabled: false }")
        web_config.save

        expect(instance_eval("application.web_config.#{endpoint}['enabled']")).to eq false
      end
    end
  end
end
