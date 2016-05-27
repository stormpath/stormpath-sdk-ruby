module Stormpath
  module Resource
    class PasswordPolicy < Stormpath::Resource::Instance
      prop_accessor :reset_token_ttl, :reset_email_status, :reset_success_email_status

      has_one :strength, class_name: :passwordPolicyStrength
      has_many :reset_email_templates
      has_many :reset_success_email_templates
    end
  end
end
