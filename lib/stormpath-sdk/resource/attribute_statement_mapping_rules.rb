class Stormpath::Resource::AttributeStatementMappingRules < Stormpath::Resource::Instance
  prop_accessor :items
  prop_reader :href, :created_at, :modified_at
end
