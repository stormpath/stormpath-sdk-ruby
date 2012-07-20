require "stormpath-sdk"

include Stormpath::Client
include Stormpath::Resource

describe "READ Operations" do

  before(:all) do
    apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @client = Client.new apiKey, 'http://localhost:8080/v1'
    @tenant = @client.current_tenant
    @dataStore = @client.dataStore
  end

  it "client should be created from api_key" do
    @client.should be_instance_of Client
  end

  it "tenant's properties must come complete'" do

    @tenant.should be_kind_of Tenant

    key = @tenant.get_key
    name = @tenant.get_name

    key.should be_kind_of String
    name.should be_kind_of String

    applications = @tenant.get_applications

    applications.should be_kind_of ApplicationList

    # checking the tenant's' applications
    applications.each { |app|

      app.should be_kind_of Application

      appName = app.get_name

      # just checking that at least one
      # application property can be read from here
      appName.should be_kind_of String
    }

    directories = @tenant.get_directories

    directories.should be_kind_of DirectoryList

    # checking the tenant's' directories
    directories.each { |dir|

      dir.should be_kind_of Directory

      dirName = dir.get_name

      # just checking that at least one
      # directory property can be read from here
      dirName.should be_kind_of String
    }

  end

  it "application's properties must come complete'" do

    href = 'applications/A0atUpZARYGApaN5f88O3A'
    application = @dataStore.get_resource href, Application

    application.should be_kind_of Application

    name = application.get_name
    status = application.get_status
    description = application.get_description
    tenant = application.get_tenant
    accounts = application.get_accounts
    passwordResetTokens = application.get_password_reset_token

    name.should be_kind_of String
    status.should be_kind_of String
    description.should be_kind_of String
    tenant.should be_kind_of Tenant
    accounts.should be_kind_of AccountList
    passwordResetTokens.should be_kind_of PasswordResetToken

    accounts.each { |acc|

      acc.should be_kind_of Account

      accName = acc.get_username

      # just checking that at least one
      # account property can be read from here
      accName.should be_kind_of String
    }


  end

  it "directory's properties must come complete'" do

    href = 'directories/_oIg8zU5QWyiz22DcVYVLg'
    directory = @dataStore.get_resource href, Directory

    directory.should be_kind_of Directory

    name = directory.get_name
    status = directory.get_status
    description = directory.get_description
    tenant = directory.get_tenant
    accounts = directory.get_accounts
    groups = directory.get_groups

    name.should be_kind_of String
    status.should be_kind_of String
    description.should be_kind_of String
    tenant.should be_kind_of Tenant
    accounts.should be_kind_of AccountList
    groups.should be_kind_of GroupList

    accounts.each { |acc|

      acc.should be_kind_of Account

      accName = acc.get_username

      # just checking that at least one
      # account property can be read from here
      accName.should be_kind_of String
    }

    groups.each { |group|

      group.should be_kind_of Group

      groupName = group.get_name

      # just checking that at least one
      # group property can be read from here
      groupName.should be_kind_of String
    }


  end

  it "group's properties must come complete'" do

    href = 'groups/Ki3qEVTeSZmaRUgAdf9h_w'
    group = @dataStore.get_resource href, Group

    group.should be_kind_of Group

    name = group.get_name
    status = group.get_status
    description = group.get_description
    tenant = group.get_tenant
    accounts = group.get_accounts
    directory = group.get_directory

    name.should be_kind_of String
    status.should be_kind_of String
    description.should be_kind_of String
    tenant.should be_kind_of Tenant
    accounts.should be_kind_of AccountList
    directory.should be_kind_of Directory

    accounts.each { |acc|

      acc.should be_kind_of Account

      accName = acc.get_username

      # just checking that at least one
      # account property can be read from here
      accName.should be_kind_of String
    }


  end

  it "account's properties must come complete'" do

    href = 'accounts/9T-6HmQ5SsygYGH1xDcysQ'
    account = @dataStore.get_resource href, Account

    account.should be_kind_of Account

    username = account.get_username
    status = account.get_status
    email = account.get_email
    givenName = account.get_given_name
    middleName = account.get_middle_name
    surname = account.get_surname
    groups = account.get_groups
    directory = account.get_directory
    emailVerificationToken = account.get_email_verification_token
    groupMemberShips = account.get_group_memberships

    username.should be_kind_of String
    status.should be_kind_of String
    email.should be_kind_of String
    givenName.should be_kind_of String
    #  middleName is optional
    #middleName.should be_kind_of String
    surname.should be_kind_of String
    groups.should be_kind_of GroupList
    directory.should be_kind_of Directory
    emailVerificationToken.should be_kind_of EmailVerificationToken
    groupMemberShips.should be_kind_of GroupMembershipList

    groups.each { |group|

      group.should be_kind_of Group

      groupName = group.get_name

      # just checking that at least one
      # group property can be read from here
      groupName.should be_kind_of String
    }

    groupMemberShips.each { |groupMembership|

      groupMembership.should be_kind_of GroupMembership

      group = groupMembership.get_group

      if (!group.nil?)

        groupName = group.get_name

        # just checking that at least one
        # group property can be read from here
        groupName.should be_kind_of String

      end
    }


  end

end



