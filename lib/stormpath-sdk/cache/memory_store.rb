module Stormpath
  module Cache
    class MemoryStore
      def initialize(opts = nil)
        @store = {}
      end

      def get(key)
        @store[key]
      end

      def put(key, entry)
        @store[key] = entry
      end

      def delete(key)
        @store.delete key
      end

      def clear
        @store.clear
      end

      def size
        @store.size
      end
    end
  end
end
