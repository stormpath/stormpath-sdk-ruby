require "stormpath-sdk"

include Stormpath::Client

describe Client do

  before(:all) do
    apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @client = Client.new apiKey, 'http://localhost:8080/v1'
  end

  it "client should be created from api_key" do
    @client.should be_instance_of Client
  end

  it "tenant's properties must come complete'" do

    tenant = @client.current_tenant
    key = tenant.get_key
    name = tenant.get_name

    applications = tenant.get_applications

    # checking the tenant's' applications
    applications.each { |app|

      app.should be_kind_of Application

      appName = app.get_name

      accounts = app.get_accounts

      accounts.each { |acc|

        acc.should be_kind_of Account

        username = acc.get_username

        username.should be_kind_of String
      }

      # just checking that at least one
      # property can be read from here
      appName.should be_kind_of String
    }

    directories = tenant.get_directories

    # checking the tenant's' directories
    directories.each { |dir|

      dir.should be_kind_of Directory

      dirName = dir.get_name

      # just checking that at least one
      # property can be read from here
      dirName.should be_kind_of String
    }

    key.should be_kind_of String
    name.should be_kind_of String
    applications.should be_kind_of ApplicationList
    directories.should be_kind_of DirectoryList
  end
end



