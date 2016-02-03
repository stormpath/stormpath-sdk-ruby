class Stormpath::Resource::SamlPolicy < Stormpath::Resource::Base
  prop_accessor :authorized_callback_uris

  def set_options(options)
    set_property :authorized_callback_uris, options[:authorized_callback_uris]
  end
end
