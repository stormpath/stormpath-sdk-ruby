module Stormpath

  module DataStore

    class ResourceFactory

      def initialize(dataStore)

        @dataStore = dataStore
      end

      def instantiate(clazz, constructorArgs)

        clazz.new @dataStore, constructorArgs
      end

    end

  end

end

