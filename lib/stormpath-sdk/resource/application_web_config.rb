class Stormpath::Resource::ApplicationWebConfig < Stormpath::Resource::Instance
  ENDPOINTS = [:oauth2, :register, :login, :verify_email, :forgot_password, :change_password, :me].freeze
  prop_accessor :dns_label, :status, *ENDPOINTS
  prop_reader :domain_name, :created_at, :modified_at

  has_one :signing_api_key, class_name: :api_key
  belongs_to :application
  belongs_to :tenant
end
