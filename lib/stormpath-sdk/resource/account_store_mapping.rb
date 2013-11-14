class Stormpath::Resource::AccountStoreMapping < Stormpah::Resource::Instance

  belongs_to: :application, can: [:get]

end