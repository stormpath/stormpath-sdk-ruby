module Stormpath
  module Resource
    module AccountOverrides
      extend ActiveSupport::Concern

      included do
        def create_account(account, registration_workflow_enabled = nil)
          href = accounts.href
          if registration_workflow_enabled == false
            href += "?registrationWorkflowEnabled=#{registration_workflow_enabled}"
          end

          resource = case account
                     when Stormpath::Resource::Base
                       account
                     else
                       Stormpath::Resource::Account.new account, client
                     end

          resource.apply_custom_data_updates_if_necessary
          data_store.create(href, resource, Stormpath::Resource::Account)
        end
      end
    end
  end
end
