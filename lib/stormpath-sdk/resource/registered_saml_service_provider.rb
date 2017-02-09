module Stormpath
  module Resource
    class RegisteredSamlServiceProvider < Stormpath::Resource::Instance
      prop_accessor :name, :description, :assertion_consumer_service_url, :entity_id, :name_id_format
      prop_reader :encoded_x509_certificate, :created_at, :modified_at
    end
  end
end
