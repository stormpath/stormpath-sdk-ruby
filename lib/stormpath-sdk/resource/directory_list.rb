require "stormpath-sdk/resource/collection_resource"
require "stormpath-sdk/resource/directory"

module Stormpath

  module Resource

    class DirectoryList < CollectionResource

      def initialize dataStore, properties

        super dataStore, properties

      end

      def get_item_type
        Directory
      end

    end

  end
end

