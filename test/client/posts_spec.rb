require "stormpath-sdk"

include Stormpath::Authentication

describe "POST Operations" do

  before(:all) do
    apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @client = Client.new apiKey, 'http://localhost:8080/v1'
    @dataStore = @client.dataStore
    @createAccount = false
    @updateAccount = false
    @updateApplication = false
    @updateDirectory = false
    @updateGroup = false
  end

  it "application should be able to authenticate" do

    href = 'applications/A0atUpZARYGApaN5f88O3A'
    application = @dataStore.get_resource href, Application

    result = application.authenticate UsernamePasswordRequest.new 'kentucky', 'super_P4ss', nil

    result.should be_kind_of Account
  end

  it "directory should be able to create account" do

    if (@createAccount)

      href = 'directories/_oIg8zU5QWyiz22DcVYVLg'
      directory = @dataStore.get_resource href, Directory

      account = Account.new @dataStore, nil
      account.set_email 'rubysdk@email.com'
      account.set_given_name 'Ruby'
      account.set_password 'super_P4ss'
      account.set_surname 'Sdk'
      account.set_username 'rubysdk'

      result = directory.create_account account, false

      result.should be_kind_of Account

    end

  end

  it "account should be updated" do

    if (@updateAccount)

      href = 'accounts/9T-6HmQ5SsygYGH1xDcysQ'
      account = @dataStore.get_resource href, Account

      account.set_middle_name 'Modified'
      account.set_status Status::ENABLED

      account.save

      account.get_middle_name.should be_kind_of String

    end

  end

  it "application should be updated" do

    if (@updateApplication)

      href = 'applications/A0atUpZARYGApaN5f88O3A'
      application = @dataStore.get_resource href, Application

      application.set_name application.get_name + ' Modified'
      application.set_status Status::ENABLED

      application.save

      application.get_name.should be_kind_of String

    end

  end

  it "directory should be updated" do

    if (@updateDirectory)

      href = 'directories/_oIg8zU5QWyiz22DcVYVLg'
      directory = @dataStore.get_resource href, Directory

      directory.set_name directory.get_name + ' Modified'
      directory.set_status Status::ENABLED

      directory.save

      directory.get_name.should be_kind_of String

    end

  end

  it "group should be updated" do

    if (@updateGroup)

      href = 'groups/Ki3qEVTeSZmaRUgAdf9h_w'
      group = @dataStore.get_resource href, Directory

      group.set_name group.get_name + ' Modified'
      group.set_status Status::ENABLED

      group.save

      group.get_name.should be_kind_of String

    end

  end


end