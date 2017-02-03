# The wait_for_custom_data_indexing method is used throughout the specs when we search
# the recently saved custom data. Since Elasticsearch is being used in the backend,
# a small time period is needed for the data to finish indexing.
module Stormpath
  module Test
    module CustomDataSavePeriod
      def wait_for_custom_data_indexing
        sleep 5
      end

      def wait_for_directory_creation
        sleep 4
      end
    end
  end
end
