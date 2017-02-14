module Stormpath
  module Resource
    class Agent < Stormpath::Resource::Instance
      prop_reader :id, :download, :created_at, :modified_at
      prop_accessor :status, :config

      belongs_to :directory
      belongs_to :tenant

      alias download_prop_reader download

      def download
        download_prop_reader['href']
      end
    end
  end
end
