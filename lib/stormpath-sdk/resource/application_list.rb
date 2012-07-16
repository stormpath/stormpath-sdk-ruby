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

