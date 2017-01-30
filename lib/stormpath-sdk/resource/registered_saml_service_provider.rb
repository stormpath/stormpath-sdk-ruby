module Stormpath
  module Resource
    class RegisteredSamlServiceProvider < Stormpath::Resource::Instance
      prop_reader :created_at, :modified_at, :name, :description, :assertion_consumer_service_url,
                  :entity_id, :encoded_x509_certificate
      prop_accessor :name_id_format
    end
  end
end
