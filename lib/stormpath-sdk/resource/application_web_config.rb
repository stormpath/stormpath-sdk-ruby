class Stormpath::Resource::ApplicationWebConfig < Stormpath::Resource::Instance
  prop_accessor :dns_label, :status, :oauth2, :register, :login, :verify_email, :forgot_password, :change_password, :me
  prop_reader :domain_name, :created_at, :modified_at

  has_one :signing_api_key, class_name: :api_key
  belongs_to :application
  belongs_to :tenant
end
