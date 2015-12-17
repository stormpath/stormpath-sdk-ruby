module Stormpath
  module Test
      def self.mocked_account(provider)
        if provider.to_sym == :google
          MultiJson.dump(GOOGLE_ACCOUNT)
        elsif provider.to_sym == :facebook
          MultiJson.dump(FACEBOOK_ACCOUNT)
        elsif provider.to_sym == :linkedin
          MultiJson.dump(LINKEDIN_ACCOUNT)
        end
      end

      def self.mocked_provider_data(provider)
        if provider.to_sym == :google
          MultiJson.dump(GOOGLE_PROVIDER_DATA)
        elsif provider.to_sym == :facebook
          MultiJson.dump(FACEBOOK_PROVIDER_DATA)
        elsif provider.to_sym == :linkedin
          MultiJson.dump(LINKEDIN_PROVIDER_DATA)
        end
      end

      FACEBOOK_ACCOUNT = {
        href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7",
        username: "damir.svrtan", 
        email: "hladnidamir@hotmail.com", 
        givenName: "Damir", 
        middleName: nil, 
        surname: "Svrtan", 
        fullName: "Damir Svrtan", 
        status: "ENABLED", 
        emailVerificationToken: nil, 
        customData: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData"}, 
        providerData: { href:"https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData"}, 
        directory: { href: "https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP"}, 
        tenant: { href: "https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk"}, 
        groups: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups"}, 
        groupMemberships: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships"}
      }

      FACEBOOK_PROVIDER_DATA = {
        href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData",
        createdAt: "2014-05-19T13:32:16.884Z",
        modifiedAt: "2014-05-19T13:32:16.927Z",
        accessToken: "CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD",
        providerId: "facebook"
      }

      LINKEDIN_ACCOUNT = {
        href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7",
        username: "nenad.nikolic", 
        email: "nnikolic87@gmail.com", 
        givenName: "Nenad", 
        middleName: nil, 
        surname: "Nikolic", 
        fullName: "Nenad Nikolic", 
        status: "ENABLED", 
        emailVerificationToken: nil, 
        customData: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData"}, 
        providerData: { href:"https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData"}, 
        directory: { href: "https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP"}, 
        tenant: { href: "https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk"}, 
        groups: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups"}, 
        groupMemberships: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships"}
      }

      LINKEDIN_PROVIDER_DATA = {
        href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData",
        createdAt: "2014-05-19T13:32:16.884Z",
        modifiedAt: "2014-05-19T13:32:16.927Z",
        accessToken: "CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD",
        providerId: "linkedin"
      }

      GOOGLE_ACCOUNT = {
        href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj", 
        username: "damir.svrtan@gmail.com", 
        email: "damir.svrtan@gmail.com", 
        givenName: "Damir", 
        middleName: nil, 
        surname: "Svrtan", 
        fullName: "Damir Svrtan", 
        status: "ENABLED", 
        emailVerificationToken: nil, 
        customData: { href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/customData" }, 
        providerData: { href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/providerData" }, 
        directory: { href: "https://api.stormpath.com/v1/directories/2WU9sRpSn5jpVADlQTAltT" }, 
        tenant: { href: "https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk" },
        groups: { href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/groups" },
        groupMemberships: { href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/groupMemberships" }
      }

      GOOGLE_PROVIDER_DATA = {
        href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/providerData",
        createdAt: "2014-05-19T13:34:40.131Z",
        modifiedAt: "2014-05-19T13:34:40.172Z", 
        accessToken: "ya29.GwCFxf7GuqpKOx8AAACnZZvl-TR_UAqpwVHHfUlt-nM_yjVel2FiqjMgAoOtxQ",
        providerId: "google",
        refreshToken: "Ox8AAACn"
      }
  end
end
