require 'spec_helper'

describe Stormpath::Resource::Agent, vcr: true do
  let(:directory_name) { "rubysdkdirldap-#{random_number}" }
  let(:directory) do
    test_api_client.directories.create(
      name: directory_name,
      description: directory_name,
      provider: {
        provider_id: 'ldap',
        agent: ldap_agent_attrs
      }
    )
  end
  let(:agent) { directory.provider.agent }

  after { directory.delete }

  it 'instances should respond to attribute property methods' do
    expect(agent).to be_a Stormpath::Resource::Agent

    [:id, :download, :created_at, :modified_at].each do |property_getter|
      expect(agent).to respond_to(property_getter)
      expect(agent.send(property_getter)).to be_a String
    end

    [:config, :status].each do |property_accessor|
      expect(agent).to respond_to(property_accessor)
      expect(agent).to respond_to("#{property_accessor}=")
    end

    expect(agent.config).to be_a Hash
    expect(agent.status).to be_a String
  end

  describe 'associations' do
    it 'should respond to directory' do
      expect(agent.directory).to eq directory
    end

    it 'should respond to tenant' do
      expect(agent.tenant).to eq test_api_client.tenant
    end
  end
end
