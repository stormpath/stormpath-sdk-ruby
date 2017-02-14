module Stormpath
  module Resource
    class AttributeStatementMappingRules < Stormpath::Resource::Instance
      prop_accessor :items
      prop_reader :href, :created_at, :modified_at

      def mapping_rules?
        true
      end
    end
  end
end
