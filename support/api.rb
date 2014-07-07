module Stormpath
  module Support
    class Api
      def self.destroy_resources(
        api_key_id, api_key_secret, application_url,
        directory_url, directory_with_verification_url
      )

        api_key = Stormpath::ApiKey.new(
          api_key_id, api_key_secret
        )

        Stormpath::Client.new(api_key: api_key).tap do |client|
          delete_applications client.applications, application_url

          client.directories.each do |dir|
            delete_accounts dir.accounts

            unless [directory_url, directory_with_verification_url].include? dir.href
              delete_directory dir
            end
          end
        end
      end

      def self.delete_applications applications, application_url
        applications.each do |app|
          begin
            app.delete if app.href != application_url
          rescue Stormpath::Error => e
            raise e if e.message != "System Application cannot be deleted!!!"
          end
        end
      end

      def self.delete_accounts accounts
        accounts.each do |account|
          begin
            account.delete
          rescue Stormpath::Error => e
            raise e unless e.code == 4001
          end
        end
      end

      def self.delete_directory directory
        begin
          directory.delete
        rescue Stormpath::Error => e
          raise e if e.message != "System Directory cannot be deleted!"
        end
      end
    end
  end
end