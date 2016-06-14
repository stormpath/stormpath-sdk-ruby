module Stormpath
  module Resource
    class EmailTemplate < Stormpath::Resource::Instance
      prop_accessor :name, :description, :subject, :from_email_address, :text_body, :html_body, :mime_type
    end
  end
end
