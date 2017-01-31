module Stormpath
  module Cache
    class DisabledCacheStore
      def initialize(opts = nil); end

      def get(key); end

      def put(_key, entry)
        entry
      end

      def delete(key); end

      def clear
        {}
      end

      def size
        0
      end
    end
  end
end
