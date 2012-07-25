module Stormpath

  module Resource

    class AccountList < CollectionResource

      def get_item_type

        Account

      end
    end

  end

end

