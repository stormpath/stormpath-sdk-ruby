class Stormpath::Resource::AccountStoreMapping < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  prop_accessor :list_index, :is_default_account_store, :is_default_group_store

  belongs_to :application

  def account_store_href
    get_property("accountStore")["href"]
  end

  def is_directory?(directory_or_group_href)
    /directories/.match directory_or_group_href
  end

  def account_store
    directory_or_group_href = account_store_href
    if is_directory? directory_or_group_href
      client.directories.get directory_or_group_href
    else
      client.groups.get directory_or_group_href
    end
  end

  alias_method :default_account_store, :is_default_account_store
  alias_method :default_account_store?, :is_default_account_store
  alias_method :default_group_store, :is_default_group_store
  alias_method :default_group_store?, :is_default_group_store

end

