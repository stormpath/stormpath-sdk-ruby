module Stormpath

  module Resource

    class GroupMembershipList < CollectionResource

      def get_item_type

        GroupMembership

      end

    end

  end

end