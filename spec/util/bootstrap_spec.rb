require 'spec_helper'

def destroy_all_stormpath_test_resources api_key
  client = Stormpath::Client.new({
    api_key: api_key
  })

  tenant = client.current_tenant

  directories = tenant.get_directories

  directories.each do |dir|
    dir.delete if dir.get_name.start_with? 'TestDirectory'
  end

  applications = tenant.get_applications

  applications.each do |app|
    app.delete if app.get_name.start_with? 'TestApplication'
  end
end

describe Stormpath::Util::Bootstrapper do
  let(:test_api_key_id) { ENV['STORMPATH_TEST_API_KEY_ID'] }
  let(:test_api_key_secret) { ENV['STORMPATH_TEST_API_KEY_SECRET'] }
  let(:test_api_key) { Stormpath::ApiKey.new test_api_key_id, test_api_key_secret }

  before do
    unless test_api_key_id and test_api_key_secret
      raise <<needs_setup
In order to run these tests, you need to define the
STORMPATH_TEST_API_KEY_ID and STORMPATH_TEST_API_KEY_SECRET
needs_setup
    end
  end

  describe '.bootstrap' do
    context 'given the location of a properties file' do
      let(:application_name) { "TestApplication#{Time.now.to_i}" }
      let(:directory_name) { "TestDirectory#{Time.now.to_i}" }
      let(:output_configuration_file) { File.join(File.dirname(__FILE__), 'stormpath.yml') }
      let!(:bundle) do
        Stormpath::Util::Bootstrapper.bootstrap({
          api_key: test_api_key,
          application_name: application_name,
          directory_names: [ directory_name ],
          output_configuration_file: output_configuration_file
        })
      end

      before do
        destroy_all_stormpath_test_resources test_api_key
      end

      after do
        File.delete(output_configuration_file) if File.exists? output_configuration_file
        destroy_all_stormpath_test_resources test_api_key
      end

      it "creates an application for the API key's tenant" do
        bundle.application.should be
        bundle.application.get_name.should == application_name
      end

      it "creates a directory for the API key's tenant" do
        bundle.directories.should be
        bundle.directories.should have(1).directory
        bundle.directories[directory_name].should be
        bundle.directories[directory_name].get_name.should == directory_name
      end

      it "writes out a configuration YAML with the URLs to the application and directory" do
        File.exists?(output_configuration_file).should be_true
        stormpath_yml = YAML::load IO.read output_configuration_file

        stormpath_yml['common']['stormpath_url'].should == bundle.application.get_href
        stormpath_yml[directory_name]['root'].should == bundle.directories[directory_name].get_href
      end
    end
  end
end
