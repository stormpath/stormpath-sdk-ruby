module Stormpath
  module Resource
    class RegisteredSamlServiceProvider < Stormpath::Resource::Instance
      prop_reader :name, :description, :assertion_consumer_service_u_r_l, :entity_id,
                  :name_id_format, :encoded_x509_certificate, :created_at, :modified_at

      alias assertion_consumer_service_url assertion_consumer_service_u_r_l
    end
  end
end
