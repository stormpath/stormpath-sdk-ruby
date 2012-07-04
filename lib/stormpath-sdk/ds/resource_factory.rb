module Stormpath

  module DataStore

    class ResourceFactory

      def initialize(dataStore)

        @dataStore = dataStore
      end

      def instantiate(clazz, data)

        clazz.new @dataStore, data
      end

    end

  end

end

