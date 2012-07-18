module Stormpath

  module Resource

    class GroupMembershipList < CollectionResource

      def initialize dataStore, properties

        super dataStore, properties

      end

      def get_item_type

        GroupMembership

      end

    end

  end

end