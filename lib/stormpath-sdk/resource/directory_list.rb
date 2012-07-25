module Stormpath

  module Resource

    class DirectoryList < CollectionResource

      def get_item_type
        Directory
      end

    end

  end
end

