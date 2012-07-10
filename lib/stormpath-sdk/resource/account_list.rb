require "stormpath-sdk/resource/collection_resource"
require "stormpath-sdk/resource/account"

module Stormpath

  module Resource

    class AccountList < CollectionResource

      def initialize dataStore, properties

        super dataStore, properties

      end

      def get_item_type

        Account

      end
    end

  end

end

