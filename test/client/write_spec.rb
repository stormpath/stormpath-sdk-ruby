require "stormpath-sdk"

include Stormpath::Authentication

describe "WRITE Operations" do

  before(:all) do
    apiKey = ApiKey.new '4OCDGOGPLVQW8FZO49N5EMZE9', 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    @client = Client.new apiKey, 'http://localhost:8080/v1'
    @dataStore = @client.dataStore
    @createAccount = false
    @updateAccount = false
    @updateApplication = false
    @updateDirectory = false
    @updateGroup = false
    @createApplication = false
    @verifyEmail = false
    @createPasswordResetToken = false
    @verifyPasswordResetToken = false
    @createGroupMemberShipFromAccount = false
    @createGroupMemberShipFromGroup = false
    @updateGroupMembershipWithDeletion = false
  end

  it "application should be able to authenticate" do

    href = 'applications/A0atUpZARYGApaN5f88O3A'
    application = @dataStore.get_resource href, Application

    result = application.authenticate UsernamePasswordRequest.new 'kentucky', 'super_P4ss', nil

    result.should be_kind_of Account
  end

  it "application should NOT be able to authenticate and catch the error" do

    begin

      href = 'applications/A0atUpZARYGApaN5f88O3A'
      application = @dataStore.get_resource href, Application
      result = application.authenticate UsernamePasswordRequest.new 'kentucky', 'WRONG_PASS', nil

    rescue ResourceError => re
      p '** Authentication Error **'
      p 'Message: ' + re.message
      p 'HTTP Status: ' + re.get_status.to_s
      p 'Developer Message: ' + re.get_developer_message
      p 'More Information: ' + re.get_more_info
      p 'Error Code: ' + re.get_code.to_s
    end

    result.should_not be_kind_of Account
  end

  it "directory should be able to create account" do

    if (@createAccount)

      href = 'directories/_oIg8zU5QWyiz22DcVYVLg'
      directory = @dataStore.get_resource href, Directory

      account = @dataStore.instantiate Account, nil
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
      group = @dataStore.get_resource href, Group

      group.set_name group.get_name + ' Modified'
      group.set_status Status::ENABLED

      group.save

      group.get_name.should be_kind_of String

    end

  end

  it "application should be created" do

    if (@createApplication)

      tenant = @client.current_tenant

      application = @dataStore.instantiate Application, nil
      application.set_name 'Test Application Creation'
      application.set_description 'Test Application Description'

      result = tenant.create_application application

      result.should be_kind_of Application

    end

  end

  it "email should get verified" do

    if (@verifyEmail)

      verificationToken = 'ujhNWAIVT2Wtfk-no3ajtw'

      tenant = @client.current_tenant

      result = tenant.verify_account_email verificationToken

      result.should be_kind_of Account

    end

  end

  it "password reset token should be created" do

    if (@createPasswordResetToken)

      href = 'applications/A0atUpZARYGApaN5f88O3A'
      application = @dataStore.get_resource href, Application

      passwordResetToken = application.create_password_reset_token 'rubysdk@email.com'

      passwordResetToken.should be_kind_of PasswordResetToken

    end

  end

  it "password reset token should be verified" do

    if (@verifyPasswordResetToken)

      href = 'applications/A0atUpZARYGApaN5f88O3A'
      application = @dataStore.get_resource href, Application

      passwordResetToken = application.verify_password_reset_token 'XW1AAKnlT-6sX0KEvLAbDg'

      passwordResetToken.should be_kind_of PasswordResetToken

    end

  end

  it "account should be linked to specified group" do

    if (@createGroupMemberShipFromAccount)

      groupHref = 'groups/Ki3qEVTeSZmaRUgAdf9h_w'
      group = @dataStore.get_resource groupHref, Group

      accountHref = 'accounts/9T-6HmQ5SsygYGH1xDcysQ'
      account = @dataStore.get_resource accountHref, Account

      account.add_group group

      groupLinked = false
      account.get_group_memberships.each { |groupMembership|

        group = groupMembership.get_group

        if (!group.nil? and group.get_href.include? groupHref)
          groupLinked = true
          break
        end
      }

      groupLinked.should == true

    end

  end


  it "group should be linked to specified account" do

    if (@createGroupMemberShipFromGroup)

      groupHref = 'groups/1h9hasRvRr-8sx5GeJN_Dg'
      group = @dataStore.get_resource groupHref, Group

      accountHref = 'accounts/9T-6HmQ5SsygYGH1xDcysQ'
      account = @dataStore.get_resource accountHref, Account

      group.add_account account

      accountLinked = false
      group.get_accounts.each { |tmpAccount|

        if (tmpAccount.get_href.include? accountHref)
          accountLinked = true
          break
        end
      }

      accountLinked.should == true

    end

  end

  it "group membership should be updated with deletion/creation" do

    if (@updateGroupMembershipWithDeletion)

      groupHref = 'groups/1h9hasRvRr-8sx5GeJN_Dg'
      group = @dataStore.get_resource groupHref, Group

      accountHref = 'accounts/9T-6HmQ5SsygYGH1xDcysQ'
      account = @dataStore.get_resource accountHref, Account

      groupLinked = false
      groupMembership = nil
      account.get_group_memberships.each { |tmpGroupMembership|

        groupMembership = tmpGroupMembership
        tmpGroup = groupMembership.get_group

        if (!tmpGroup.nil? and tmpGroup.get_href.include? groupHref)
          groupLinked = true
          break
        end
      }

      if (!groupLinked)
        groupMembership.delete
        group.add_account account
      end

      account.get_group_memberships.each { |tmpGroupMembership|

        tmpGroup = tmpGroupMembership.get_group

        if (!tmpGroup.nil? and tmpGroup.get_href.include? groupHref)
          groupMembership = tmpGroupMembership
          break
        end
      }

      groupMembership.get_group.get_href.should include groupHref

    end

  end

end