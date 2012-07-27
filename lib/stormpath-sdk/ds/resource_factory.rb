module Stormpath

  module DataStore

    class ResourceFactory

      def initialize(data_store)

        @data_store = data_store
      end

      def instantiate(clazz, constructor_args)

        clazz.new @data_store, constructor_args
      end

    end

  end

end

