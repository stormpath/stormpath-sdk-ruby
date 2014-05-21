module Stormpath
  module Test
      FACEBOOK_ACCOUNT = MultiJson.dump({
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
      })

      FACEBOOK_PROVIDER_DATA = MultiJson.dump({
        href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData",
        createdAt: "2014-05-19T13:32:16.884Z",
        modifiedAt: "2014-05-19T13:32:16.927Z",
        accessToken: "CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD",
        providerId: "facebook"
      })

      GOOGLE_ACCOUNT = MultiJson.dump({
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
      })

      GOOGLE_PROVIDER_DATA = MultiJson.dump({
        href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/providerData",
        createdAt: "2014-05-19T13:34:40.131Z",
        modifiedAt: "2014-05-19T13:34:40.172Z", 
        accessToken: "ya29.GwCFxf7GuqpKOx8AAACnZZvl-TR_UAqpwVHHfUlt-nM_yjVel2FiqjMgAoOtxQ",
        providerId: "google",
        refreshToken: nil
      })
  end
end