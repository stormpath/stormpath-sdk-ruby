require "stormpath-sdk/resource/collection_resource"
require "stormpath-sdk/resource/application"

module Stormpath

  module Resource

    class ApplicationList < CollectionResource

      def initialize dataStore, properties

        super dataStore, properties

      end

      def get_item_type

        Application

      end

    end

  end
end

