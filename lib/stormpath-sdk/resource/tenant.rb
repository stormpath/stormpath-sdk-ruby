require "stormpath-sdk/resource/instance_resource"

module Stormpath

  module Resource

    class Tenant < InstanceResource

      NAME = "name"
      KEY = "key"
      APPLICATIONS = "applications"
      DIRECTORIES = "directories"

      def initialize(dataStore, propertiesHash)
        super dataStore, propertiesHash
      end

      def get_name
        get_property NAME
      end

      def get_key
        get_property KEY
      end

      def createApplication(application)

      end

      def get_applications

      end

      def get_directories

      end

    end
  end
end