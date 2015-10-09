class Stormpath::Resource::OauthPolicy < Stormpath::Resource::Instance
  prop_accessor :access_token_ttl, :refresh_token_ttl

  belongs_to :application
end
