require 'spec_helper'

describe Stormpath::Util::Bootstrapper do
  describe '.bootstrap' do
    context 'given the location of a properties file' do
      let(:application_name) { generate_resource_name }
      let(:directory_name) { generate_resource_name }
      let(:output_configuration_file) { File.join(File.dirname(__FILE__), 'stormpath.yml') }
      let!(:bundle) do
        Stormpath::Util::Bootstrapper.bootstrap({
          api_key: test_api_key,
          application_name: application_name,
          directory_names: [ directory_name ],
          output_configuration_file: output_configuration_file
        })
      end

      after do
        File.delete(output_configuration_file) if File.exists? output_configuration_file
      end

      it "creates an application for the API key's tenant" do
        bundle.application.should be
        bundle.application.name.should == application_name
      end

      it "creates a directory for the API key's tenant" do
        bundle.directories.should be
        bundle.directories.should have(1).directory
        bundle.directories[directory_name].should be
        bundle.directories[directory_name].name.should == directory_name
      end

      it "writes out a configuration YAML with the URLs to the application and directory" do
        File.exists?(output_configuration_file).should be_true
        stormpath_yml = YAML::load IO.read output_configuration_file

        stormpath_yml['common']['stormpath_url'].should == bundle.application.href
        stormpath_yml[directory_name]['root'].should == bundle.directories[directory_name].href
      end
    end
  end
end
