module Stormpath
  module Cache
    class CacheEntry
      attr_accessor :value, :created_at, :last_accessed_at

      def initialize value
        self.value            = value
        self.created_at       = Time.now
        self.last_accessed_at = created_at
      end

      def touch
        self.last_accessed_at = Time.now
      end

      def expired? ttl_seconds, tti_seconds
        now = Time.now
        now > (created_at + ttl_seconds) || now > (last_accessed_at + tti_seconds)
      end

      def to_h
        { 'value' => value, 'created_at' => created_at, 'last_accessed_at' => last_accessed_at }
      end

      def self.from_h(hash)
        CacheEntry.new(hash['value']).tap do |cache_entry|
          cache_entry.created_at = Time.parse(hash['created_at'])
          cache_entry.last_accessed_at = Time.parse(hash['last_accessed_at'])
        end
      end
    end
  end
end
