require 'redis'

module Stormpath
  module Cache
    class RedisStore
      def initialize(opts = {})
        @redis = Redis.new opts
      end

      def get(key)
        entry = @redis.get key
        entry && Stormpath::Cache::CacheEntry.from_h(MultiJson.load(entry))
      end

      def put(key, entry)
        @redis.set key, MultiJson.dump(entry.to_h)
      end

      def delete(key)
        @redis.del key
      end

      def clear
        @redis.flushdb
      end

      def size
        @redis.dbsize
      end
    end
  end
end
