class Stormpath::Resource::AccessToken < Stormpath::Resource::Instance
  prop_reader :access_token, :refresh_token, :token_type, :expires_in,
    :stormpath_access_token_href

  alias_method :href, :stormpath_access_token_href

  def delete
    unless href.respond_to?(:empty) and href.empty?
      data_store.delete self 
    end
  end
end
