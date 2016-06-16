module Stormpath
  module Resource
    class AccountCreationPolicy < Stormpath::Resource::Instance
      prop_accessor(
        :verification_email_status,
        :verification_success_email_status,
        :welcome_email_status
      )

      has_many :verification_email_templates, class_name: :emailTemplate
      has_many :verification_success_email_templates, class_name: :emailTemplate
      has_many :welcome_email_templates, class_name: :emailTemplate
    end
  end
end
