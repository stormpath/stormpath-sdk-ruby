module Stormpath
  module Resource
    class PasswordPolicy < Stormpath::Resource::Instance
      prop_accessor :reset_token_ttl
      has_status(name: :reset_email_status)
      has_status(name: :reset_success_email_status)

      has_one :strength, class_name: :passwordStrength
      has_many :reset_email_templates, class_name: :emailTemplate
      has_many :reset_success_email_templates, class_name: :emailTemplate
    end
  end
end
