module Stormpath
  module Cache
    class MemoryStore
      def initialize
        @store = {}
      end

      def get(k)
        @store[k]
      end

      def put(k, v)
        @store[k] = v
      end

      def delete(k)
        @store.delete k
      end

      def size
        @store.size
      end
    end
  end
end
