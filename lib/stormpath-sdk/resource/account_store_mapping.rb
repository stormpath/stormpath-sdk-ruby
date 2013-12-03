class Stormpath::Resource::AccountStoreMapping < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  prop_accessor :list_index, :is_default_account_store, :is_default_group_store

  belongs_to :application

  def account_store
     account_store_is_a_directory? ? client.directories.get(account_store_href) : client.groups.get(account_store_href)
  end

  alias_method :default_account_store, :is_default_account_store
  alias_method :default_account_store?, :is_default_account_store
  alias_method :default_group_store, :is_default_group_store
  alias_method :default_group_store?, :is_default_group_store
  alias_method :default_account_store=, :is_default_account_store=
  alias_method :default_group_store=, :is_default_group_store=

  private

    def account_store_href
      get_property("accountStore")["href"]
    end
    
    def account_store_is_a_directory?
      /directories/.match account_store_href
    end

end

