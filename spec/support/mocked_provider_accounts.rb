module Stormpath
  module Test
    def self.mocked_account(provider)
      if provider.to_sym == :google
        MultiJson.dump(GOOGLE_ACCOUNT)
      elsif provider.to_sym == :facebook
        MultiJson.dump(FACEBOOK_ACCOUNT)
      elsif provider.to_sym == :linkedin
        MultiJson.dump(LINKEDIN_ACCOUNT)
      elsif provider.to_sym == :github
        MultiJson.dump(GITHUB_ACCOUNT)
      end
    end

    def self.mocked_provider_data(provider)
      if provider.to_sym == :google
        MultiJson.dump(GOOGLE_PROVIDER_DATA)
      elsif provider.to_sym == :facebook
        MultiJson.dump(FACEBOOK_PROVIDER_DATA)
      elsif provider.to_sym == :linkedin
        MultiJson.dump(LINKEDIN_PROVIDER_DATA)
      elsif provider.to_sym == :github
        MultiJson.dump(GITHUB_PROVIDER_DATA)
      end
    end

    def self.mocked_social_grant_response
      MultiJson.dump(STORMPATH_GRANT_RESPONSE)
    end

    def self.mocked_challenge_factor_grant_response
      MultiJson.dump(STORMPATH_GRANT_RESPONSE)
    end

    def self.mocked_factor_response
      MultiJson.dump(FACTOR_RESPONSE)
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

    GITHUB_ACCOUNT = {
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

    GITHUB_PROVIDER_DATA = {
      href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData",
      createdAt: "2014-05-19T13:32:16.884Z",
      modifiedAt: "2014-05-19T13:32:16.927Z",
      accessToken: "CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD",
      providerId: "github"
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

    STORMPATH_GRANT_RESPONSE = {
      'access_token' => 'random_access_token',
      'refresh_token' => 'random_refresh_token',
      'token_type' => 'Bearer',
      'expires_in' => 3600,
      'stormpath_access_token_href' => 'random_href'
    }.freeze

    FACTOR_RESPONSE = {
      'href' => 'https://api.stormpath.com/v1/factors/29300284904',
      'type' => 'SMS',
      'verificationStatus' => 'UNVERIFIED',
      'status' => 'ENABLED',
      'account' => {
        'href' => 'https://api.stormpath.com/v1/accounts/20959204030'
      },
      'phone' => {
        'href' => 'https://api.stormpath.com/v1/phones/28394029583'
      },
      'mostRecentChallenge' => {
        'href' => 'https://api.stormpath.com/v1/challenges/28390384032'
      },
      'challenges' => {
        'href' => 'https://api.stormpath.com/v1/factors/29300284904/challenges'
      }
    }.freeze
  end
end
