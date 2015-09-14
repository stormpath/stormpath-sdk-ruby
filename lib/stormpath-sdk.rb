require "base64"
require "httpclient"
require "multi_json"
require "openssl"
require "open-uri"
require "uri"
require "uuidtools"
require "jwt"
require "yaml"
require 'active_support'
require "active_support/core_ext"
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/kernel/singleton_class'
require 'active_support/core_ext/array/wrap'

require "stormpath-sdk/version" unless defined? Stormpath::VERSION

require "stormpath-sdk/util/assert"

module Stormpath
  autoload :Error, 'stormpath-sdk/error'
  autoload :ApiKey, 'stormpath-sdk/api_key'
  autoload :Client, 'stormpath-sdk/client'
  autoload :DataStore, 'stormpath-sdk/data_store'

  module Resource
    autoload :Expansion, 'stormpath-sdk/resource/expansion'
    autoload :Status, 'stormpath-sdk/resource/status'
    autoload :AccountStatus, 'stormpath-sdk/resource/account_status'
    autoload :Utils, 'stormpath-sdk/resource/utils'
    autoload :Associations, 'stormpath-sdk/resource/associations'
    autoload :Base, 'stormpath-sdk/resource/base'
    autoload :Error, 'stormpath-sdk/resource/error'
    autoload :Instance, 'stormpath-sdk/resource/instance'
    autoload :Collection, 'stormpath-sdk/resource/collection'
    autoload :CustomData, 'stormpath-sdk/resource/custom_data'
    autoload :CustomDataStorage, 'stormpath-sdk/resource/custom_data_storage'
    autoload :CustomDataHashMethods, 'stormpath-sdk/resource/custom_data_hash_methods'
    autoload :Tenant, 'stormpath-sdk/resource/tenant'
    autoload :Application, 'stormpath-sdk/resource/application'
    autoload :Directory, 'stormpath-sdk/resource/directory'
    autoload :Account, 'stormpath-sdk/resource/account'
    autoload :AccountStore, 'stormpath-sdk/resource/account_store'
    autoload :AccountStoreMapping, 'stormpath-sdk/resource/account_store_mapping'
    autoload :Group, 'stormpath-sdk/resource/group'
    autoload :EmailVerificationToken, 'stormpath-sdk/resource/email_verification_token'
    autoload :GroupMembership, 'stormpath-sdk/resource/group_membership'
    autoload :AccountMembership, 'stormpath-sdk/resource/account_membership'
    autoload :PasswordResetToken, 'stormpath-sdk/resource/password_reset_token'
  end

  module Cache
    autoload :CacheManager, 'stormpath-sdk/cache/cache_manager'
    autoload :Cache, 'stormpath-sdk/cache/cache'
    autoload :CacheEntry, 'stormpath-sdk/cache/cache_entry'
    autoload :CacheStats, 'stormpath-sdk/cache/cache_stats'
    autoload :MemoryStore, 'stormpath-sdk/cache/memory_store'
    autoload :RedisStore, 'stormpath-sdk/cache/redis_store'
    autoload :DisabledCacheStore, 'stormpath-sdk/cache/disabled_cache_store'
  end

  module Authentication
    autoload :UsernamePasswordRequest, "stormpath-sdk/auth/username_password_request"
    autoload :BasicLoginAttempt, "stormpath-sdk/auth/basic_login_attempt"
    autoload :AuthenticationResult, "stormpath-sdk/auth/authentication_result"
    autoload :BasicAuthenticator, "stormpath-sdk/auth/basic_authenticator"
  end

  module Provider
    autoload :AccountResolver, "stormpath-sdk/provider/account_resolver"
    autoload :AccountAccess, "stormpath-sdk/provider/account_access"
    autoload :AccountResult, "stormpath-sdk/provider/account_result"
    autoload :AccountRequest, "stormpath-sdk/provider/account_request"
    autoload :Provider, 'stormpath-sdk/provider/provider'
    autoload :ProviderData, 'stormpath-sdk/provider/provider_data'
    autoload :FacebookProvider, 'stormpath-sdk/provider/facebook/facebook_provider'
    autoload :FacebookProviderData, 'stormpath-sdk/provider/facebook/facebook_provider_data'
    autoload :GoogleProvider, 'stormpath-sdk/provider/google/google_provider'
    autoload :GoogleProviderData, 'stormpath-sdk/provider/google/google_provider_data'
    autoload :StormpathProvider, 'stormpath-sdk/provider/stormpath/stormpath_provider'
    autoload :StormpathProviderData, 'stormpath-sdk/provider/stormpath/stormpath_provider_data'
  end

  module Http
    autoload :Utils, "stormpath-sdk/http/utils"
    autoload :Request, "stormpath-sdk/http/request"
    autoload :Response, "stormpath-sdk/http/response"
    autoload :HttpClientRequestExecutor, "stormpath-sdk/http/http_client_request_executor"

    module Authc
      autoload :Sauthc1Signer, "stormpath-sdk/http/authc/sauthc1_signer"
    end
  end

  module IdSite
    autoload :IdSiteResult, 'stormpath-sdk/id_site/id_site_result'
  end
end