require "stormpath-sdk/resource/collection_resource"
require "stormpath-sdk/resource/group"

module Stormpath

  module Resource

    class GroupList < CollectionResource

      def initialize dataStore, properties

        super dataStore, properties

      end

      def get_item_type

        Group

      end

    end

  end

end

