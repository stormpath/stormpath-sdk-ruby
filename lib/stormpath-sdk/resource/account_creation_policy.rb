module Stormpath
  module Resource
    class AccountCreationPolicy < Stormpath::Resource::Instance
      prop_accessor(
        :verification_email_status,
        :verification_success_email_status,
        :welcome_email_status,
        :email_domain_whitelist,
        :email_domain_blacklist
      )

      has_many :verification_email_templates, class_name: :emailTemplate
      has_many :verification_success_email_templates, class_name: :emailTemplate
      has_many :welcome_email_templates, class_name: :emailTemplate

      [:whitelist, :blacklist].each do |list|
        ['add_to', 'remove_from'].each do |action|
          define_method("#{action}_#{list}") do |*emails|
            assert_not_blank(emails, "emails can't be blank when #{action} #{list}")
            eval("self.email_domain_#{list} #{action == 'add_to' ? '+' : '-'}= emails")
            save
          end
        end
      end
    end
  end
end
