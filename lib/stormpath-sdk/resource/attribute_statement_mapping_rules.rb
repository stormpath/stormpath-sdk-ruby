# The items property is an array of hashes which consists of:
#  - name
#  - nameFormat
#  - accountAttributes
# The nameFormat supports these values:
#   urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
#   urn:oasis:names:tc:SAML:2.0:nameid-format:entity
#   urn:oasis:names:tc:SAML:2.0:nameid-format:persistent
#   urn:oasis:names:tc:SAML:2.0:nameid-format:transient
#   urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified
#   urn:oasis:names:tc:SAML:2.0:attrname-format:basic
#   urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified
#   urn:oasis:names:tc:SAML:2.0:attrname-format:uri
module Stormpath
  module Resource
    class AttributeStatementMappingRules < Stormpath::Resource::Instance
      prop_accessor :items
      prop_reader :href, :created_at, :modified_at
    end
  end
end
