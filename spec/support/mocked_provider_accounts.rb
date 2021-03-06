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
      elsif provider.to_sym == :twitter
        MultiJson.dump(TWITTER_ACCOUNT)
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
      elsif provider.to_sym == :twitter
        MultiJson.dump(TWITTER_PROVIDER_DATA)
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

    def self.mocked_empty_challenge_response
      MultiJson.dump(EMPTY_CHALLENGE_COLLECTION_RESPONSE)
    end

    def self.mocked_challenges_response
      MultiJson.dump(CHALLENGE_COLLECTION_RESPONSE)
    end

    def self.mocked_challenge
      MultiJson.dump(CHALLENGE)
    end

    def self.mocked_successfull_challenge
      MultiJson.dump(SUCCESSFULL_CHALLENGE)
    end

    def self.mocked_failed_challenge
      MultiJson.dump(FAILED_CHALLENGE)
    end

    FACEBOOK_ACCOUNT = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7',
      username: 'damir.svrtan',
      email: 'hladnidamir@hotmail.com',
      givenName: 'Damir',
      middleName: nil,
      surname: 'Svrtan',
      fullName: 'Damir Svrtan',
      status: 'ENABLED',
      emailVerificationToken: nil,
      customData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData' },
      providerData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData' },
      directory: { href: 'https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP' },
      tenant: { href: 'https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk' },
      groups: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups' },
      groupMemberships: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships' }
    }.freeze

    FACEBOOK_PROVIDER_DATA = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData',
      createdAt: '2014-05-19T13:32:16.884Z',
      modifiedAt: '2014-05-19T13:32:16.927Z',
      accessToken: 'CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD',
      providerId: 'facebook'
    }.freeze

    LINKEDIN_ACCOUNT = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7',
      username: 'nenad.nikolic',
      email: 'nnikolic87@gmail.com',
      givenName: 'Nenad',
      middleName: nil,
      surname: 'Nikolic',
      fullName: 'Nenad Nikolic',
      status: 'ENABLED',
      emailVerificationToken: nil,
      customData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData' },
      providerData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData' },
      directory: { href: 'https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP' },
      tenant: { href: 'https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk' },
      groups: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups' },
      groupMemberships: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships' }
    }.freeze

    LINKEDIN_PROVIDER_DATA = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData',
      createdAt: '2014-05-19T13:32:16.884Z',
      modifiedAt: '2014-05-19T13:32:16.927Z',
      accessToken: 'CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD',
      providerId: 'linkedin'
    }.freeze

    GITHUB_ACCOUNT = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7',
      username: 'nenad.nikolic',
      email: 'nnikolic87@gmail.com',
      givenName: 'Nenad',
      middleName: nil,
      surname: 'Nikolic',
      fullName: 'Nenad Nikolic',
      status: 'ENABLED',
      emailVerificationToken: nil,
      customData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData' },
      providerData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData' },
      directory: { href: 'https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP' },
      tenant: { href: 'https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk' },
      groups: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups' },
      groupMemberships: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships' }
    }.freeze

    TWITTER_ACCOUNT = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7',
      username: 'nenad.nikolic',
      email: 'nnikolic87@gmail.com',
      givenName: 'Nenad',
      middleName: nil,
      surname: 'Nikolic',
      fullName: 'Nenad Nikolic',
      status: 'ENABLED',
      emailVerificationToken: nil,
      customData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData' },
      providerData: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData' },
      directory: { href: 'https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP' },
      tenant: { href: 'https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk' },
      groups: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups' },
      groupMemberships: { href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships' }
    }.freeze

    GITHUB_PROVIDER_DATA = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData',
      createdAt: '2014-05-19T13:32:16.884Z',
      modifiedAt: '2014-05-19T13:32:16.927Z',
      accessToken: 'CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD',
      providerId: 'github'
    }.freeze

    TWITTER_PROVIDER_DATA = {
      href: 'https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData',
      createdAt: '2014-05-19T13:32:16.884Z',
      modifiedAt: '2014-05-19T13:32:16.927Z',
      accessToken: 'CAATmZBgxF6rMBAPYbfBhGrVPRw27nn9fAz6bR0DBV1XGfOcSYXSBrhZCkE1y1lWue348fboRxqX7nz88KBYi05qCHw4AQoZCqyIaWedEXrV2vFVzVHo2glq6Vb1ofAWcEHva7baZAaojA8KN5DVz4UTToKgvoIMa1kjyvZCmFZBpYXoG7H3aIKoyWJzUGCDIUrcFjvjnNZBvAZDZD',
      providerId: 'twitter'
    }.freeze

    GOOGLE_ACCOUNT = {
      href: 'https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj',
      username: 'damir.svrtan@gmail.com',
      email: 'damir.svrtan@gmail.com',
      givenName: 'Damir',
      middleName: nil,
      surname: 'Svrtan',
      fullName: 'Damir Svrtan',
      status: 'ENABLED',
      emailVerificationToken: nil,
      customData: { href: 'https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/customData' },
      providerData: { href: 'https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/providerData' },
      directory: { href: 'https://api.stormpath.com/v1/directories/2WU9sRpSn5jpVADlQTAltT' },
      tenant: { href: 'https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk' },
      groups: { href: 'https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/groups' },
      groupMemberships: { href: 'https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/groupMemberships' }
    }.freeze

    GOOGLE_PROVIDER_DATA = {
      href: 'https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/providerData',
      createdAt: '2014-05-19T13:34:40.131Z',
      modifiedAt: '2014-05-19T13:34:40.172Z',
      accessToken: 'ya29.GwCFxf7GuqpKOx8AAACnZZvl-TR_UAqpwVHHfUlt-nM_yjVel2FiqjMgAoOtxQ',
      providerId: 'google',
      refreshToken: 'Ox8AAACn'
    }.freeze

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
        'href' => 'https://api.stormpath.com/v1/challenges/70xfDsguePApNdnExample'
      },
      'challenges' => {
        'href' => 'https://api.stormpath.com/v1/factors/29300284904/challenges'
      }
    }.freeze

    EMPTY_CHALLENGE_COLLECTION_RESPONSE = {
      'href' => 'https://api.stormpath.com/v1/factors/29300284904/challenges',
      'type' => 'SMS',
      'createdAt' => '2016-09-22T21:34:00.881Z',
      'modifiedAt' => '2016-09-22T21:34:00.881Z',
      'status' => 'ENABLED',
      'verificationStatus' => 'UNVERIFIED',
      'offset' => 0,
      'limit' => 25,
      'size' => 0
    }.freeze

    CHALLENGE_COLLECTION_RESPONSE = {
      'href' => 'https://api.stormpath.com/v1/factors/29300284904/challenges',
      'type' => 'SMS',
      'createdAt' => '2016-09-22T21:34:00.881Z',
      'modifiedAt' => '2016-09-22T21:34:00.881Z',
      'status' => 'ENABLED',
      'verificationStatus' => 'UNVERIFIED',
      'offset' => 0,
      'limit' => 25,
      'size' => 1,
      'items' => [
        {
          'href' => 'https://api.stormpath.com/v1/challenges/70xfDsguePApNdnExample',
          'createdAt' => '2016-09-22T22:35:44.799Z',
          'modifiedAt' => '2016-09-22T22:39:06.822Z',
          'message' => 'For the sake of example, your code is ${code}.',
          'factor' => {
            'href' => 'https://api.stormpath.com/v1/factors/29300284904'
          },
          'account' => {
            'href' => 'https://api.stormpath.com/v1/accounts/5IvkjoqcYNe3TYMYiX98vc'
          },
          'status' => 'SUCCESS'
        }
      ]
    }.freeze

    CHALLENGE = {
      'href' => 'https://api.stormpath.com/v1/challenges/70xfDsguePApNdnExample',
      'createdAt' => '2016-09-22T22:35:44.799Z',
      'modifiedAt' => '2016-09-22T22:39:06.822Z',
      'message' => 'For the sake of example, your code is ${code}.',
      'factor' => {
        'href' => 'https://api.stormpath.com/v1/factors/29300284904'
      },
      'account' => {
        'href' => 'https://api.stormpath.com/v1/accounts/5IvkjoqcYNe3TYMYiX98vc'
      },
      'status' => 'SUCCESS'
    }.freeze

    SUCCESSFULL_CHALLENGE = {
      'href' => 'https://api.stormpath.com/v1/challenges/2p5jkx09ykTSDWMmyMDdgU',
      'createdAt' => '2016-11-17T14:01:40.138Z',
      'modifiedAt' => '2016-11-17T14:02:38.773Z',
      'status' => 'SUCCESS',
      'message' => '${code}',
      'account' => { 'href' => 'https://api.stormpath.com/v1/accounts/1vxQr1xUSxftDytaO45KH2' },
      'factor' => { 'href' => 'https://api.stormpath.com/v1/factors/2p5jktg54AATahGvm6MN4Q' }
    }.freeze

    FAILED_CHALLENGE = {
      'href' => 'https://api.stormpath.com/v1/challenges/2p5jkx09ykTSDWMmyMDdgU',
      'createdAt' => '2016-11-17T14:01:40.138Z',
      'modifiedAt' => '2016-11-17T14:02:38.773Z',
      'status' => 'FAILED',
      'message' => '${code}',
      'account' => { 'href' => 'https://api.stormpath.com/v1/accounts/1vxQr1xUSxftDytaO45KH2' },
      'factor' => { 'href' => 'https://api.stormpath.com/v1/factors/2p5jktg54AATahGvm6MN4Q' }
    }.freeze
  end
end
