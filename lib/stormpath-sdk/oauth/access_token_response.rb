module Stormpath
  module Oauth
    class AccessTokenResponse < Stormpath::Resource::Base
      prop_reader :access_token, :refresh_token, :token_type, :expires_in
    end
  end
end
