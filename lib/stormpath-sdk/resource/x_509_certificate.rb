module Stormpath
  module Resource
    class X509Certificate < Stormpath::Resource::Instance
      prop_accessor :encoded_x_509_certificate, :encoded_private_key
    end
  end
end
