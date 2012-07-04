module Stormpath

  module Resource

    class Tenant

      def initialize(dataStore, propertiesHash)
        # super(dataStore, properties)   TODO: extend from instance resource
        p dataStore.to_s + propertiesHash.to_s
      end

      def getName

      end

      def getKey

      end

      def createApplication(application)

      end

      def getApplications

      end

      def getDirectories

      end

    end
  end
end