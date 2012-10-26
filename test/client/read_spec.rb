require "stormpath-sdk"

include Stormpath::Client
include Stormpath::Resource

describe "READ Operations" do

  before(:all) do
    @client = ClientBuilder.new.set_base_url('http://localhost:8080/v1').set_api_key_file_location(Dir.home + '/.stormpath/apiKey.yml').build
    @tenant = @client.current_tenant
    @data_store = @client.data_store
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

    href = 'applications/uGBNDZ7TRhm_tahanqvn9A'
    application = @data_store.get_resource href, Application

    application.should be_kind_of Application

    name = application.get_name
    status = application.get_status
    description = application.get_description
    tenant = application.get_tenant
    accounts = application.get_accounts

    name.should be_kind_of String
    status.should be_kind_of String
    description.should be_kind_of String
    tenant.should be_kind_of Tenant
    accounts.should be_kind_of AccountList

    accounts.each { |acc|

      acc.should be_kind_of Account

      acc_name = acc.get_username

      # just checking that at least one
      # account property can be read from here
      acc_name.should be_kind_of String
    }


  end

  it "directory's properties must come complete'" do

    href = 'directories/jDd1xnMYTdqP-L-m6UD1Vg'
    directory = @data_store.get_resource href, Directory

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

      acc_name = acc.get_username

      # just checking that at least one
      # account property can be read from here
      acc_name.should be_kind_of String
    }

    groups.each { |group|

      group.should be_kind_of Group

      group_name = group.get_name

      # just checking that at least one
      # group property can be read from here
      group_name.should be_kind_of String
    }


  end

  it "group's properties must come complete'" do

    href = 'groups/E_D6HFfxSFmP0wIRvvvMUA'
    group = @data_store.get_resource href, Group

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

      acc_name = acc.get_username

      # just checking that at least one
      # account property can be read from here
      acc_name.should be_kind_of String
    }


  end

  it "account's properties must come complete'" do

    href = 'accounts/AnUd9aE_RKq-v8QJfrjq0A'
    account = @data_store.get_resource href, Account

    account.should be_kind_of Account

    username = account.get_username
    status = account.get_status
    email = account.get_email
    given_name = account.get_given_name
    middle_name = account.get_middle_name
    surname = account.get_surname
    groups = account.get_groups
    directory = account.get_directory
    email_verification_token = account.get_email_verification_token
    group_memberships = account.get_group_memberships

    username.should be_kind_of String
    status.should be_kind_of String
    email.should be_kind_of String
    given_name.should be_kind_of String
    #  middle_name is optional
    #middle_name.should be_kind_of String
    surname.should be_kind_of String
    groups.should be_kind_of GroupList
    directory.should be_kind_of Directory
    # email_verification_token may not be present
    #email_verification_token.should be_kind_of EmailVerificationToken
    group_memberships.should be_kind_of GroupMembershipList

    groups.each { |group|

      group.should be_kind_of Group

      group_name = group.get_name

      # just checking that at least one
      # group property can be read from here
      group_name.should be_kind_of String
    }

    group_memberships.each { |groupMembership|

      groupMembership.should be_kind_of GroupMembership

      group = groupMembership.get_group

      if (!group.nil?)

        group_name = group.get_name

        # just checking that at least one
        # group property can be read from here
        group_name.should be_kind_of String

      end
    }


  end

  it "dirty properties must be retained after materialization" do

    account = @data_store.instantiate Account, {'href' => 'accounts/AnUd9aE_RKq-v8QJfrjq0A'}

    name = 'Name Before Materialization'

    account.set_given_name name

    account.get_surname.should be_kind_of String

    account.get_given_name.should == name
  end

end



