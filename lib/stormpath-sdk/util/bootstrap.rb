require "stormpath-sdk"

include Stormpath::Resource

module Stormpath
  module Util
    class BootstrappedBundle
      attr_accessor :application, :directories

      def to_yaml
        {
          'common' => { 'stormpath_url' => application.get_href }
        }.tap do |stormpath_config|
          directories.each do |directory_name, directory|
            stormpath_config[directory_name] = {
              'root' => directory.get_href
            }
          end
        end.to_yaml
      end
    end

    class Bootstrapper

      def self.bootstrap(options = {})
        api_key = {
          'apiKey.id' => options[:api_key][:id],
          'apiKey.secret' => options[:api_key][:secret]
        }

        client = Stormpath::ClientBuilder.new.set_api_key_properties(api_key.to_yaml).build

        application = provision_application client, options[:application_name]
        directories = {}.tap do |directories|
          options[:directory_names].each do |directory_name|
            directories[directory_name] = provision_directory client, directory_name
          end
        end

        bundle = BootstrappedBundle.new
        bundle.application = application
        bundle.directories = directories

        write_bundle bundle, options[:output_configuration_file]

        return bundle
      end

      def self.write_bundle(bundle, output_configuration_file)
        File.open(output_configuration_file, 'w+') {|f| f.write(bundle.to_yaml) }
      end

      def self.provision_directory(client, directory_name)
        directory = client.data_store.instantiate Directory
        directory.set_name directory_name
        directory = client.data_store.create '/directories', directory, Directory

        return directory
      end

      def self.provision_application(client, application_name)
        application = client.data_store.instantiate Application
        application.set_name application_name
        application = client.current_tenant.create_application application

        return application
      end

      private_class_method :provision_application, :provision_directory, :write_bundle
    end
  end
end
