require "base64"
require "httpclient"
require "multi_json"
require "openssl"
require "open-uri"
require "uri"
require "uuidtools"
require "yaml"
require "active_support/core_ext"
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/kernel/singleton_class'
require 'active_support/core_ext/array/wrap'

require "stormpath-sdk/version" unless defined? Stormpath::VERSION

require "stormpath-sdk/util/assert"
require "stormpath-sdk/ext/hash"

module Stormpath
  autoload :Error, 'stormpath-sdk/error'
  autoload :ApiKey, 'stormpath-sdk/api_key'
  autoload :Client, 'stormpath-sdk/client'
  autoload :DataStore, 'stormpath-sdk/data_store'

  module Resource
    autoload :Expansion, 'stormpath-sdk/resource/expansion'
    autoload :Status, 'stormpath-sdk/resource/status'
    autoload :Utils, 'stormpath-sdk/resource/utils'
    autoload :Associations, 'stormpath-sdk/resource/associations'
    autoload :Base, 'stormpath-sdk/resource/base'
    autoload :Error, 'stormpath-sdk/resource/error'
    autoload :Instance, 'stormpath-sdk/resource/instance'
    autoload :Collection, 'stormpath-sdk/resource/collection'
    autoload :Tenant, 'stormpath-sdk/resource/tenant'
    autoload :Application, 'stormpath-sdk/resource/application'
    autoload :Applications, 'stormpath-sdk/resource/applications'
    autoload :Directory, 'stormpath-sdk/resource/directory'
    autoload :Directories, 'stormpath-sdk/resource/directories'
    autoload :Account, 'stormpath-sdk/resource/account'
    autoload :Accounts, 'stormpath-sdk/resource/accounts'
    autoload :Group, 'stormpath-sdk/resource/group'
    autoload :Groups, 'stormpath-sdk/resource/groups'
    autoload :EmailVerificationToken, 'stormpath-sdk/resource/email_verification_token'
    autoload :GroupMembership, 'stormpath-sdk/resource/group_membership'
    autoload :GroupMemberships, 'stormpath-sdk/resource/group_memberships'
    autoload :PasswordResetToken, 'stormpath-sdk/resource/password_reset_token'
    autoload :PasswordResetTokens, 'stormpath-sdk/resource/password_reset_tokens'
  end

  module Cache
    autoload :CacheManager, 'stormpath-sdk/cache/cache_manager'
    autoload :Cache, 'stormpath-sdk/cache/cache'
    autoload :CacheStats, 'stormpath-sdk/cache/cache_stats'
    autoload :MemoryStore, 'stormpath-sdk/cache/memory_store'
  end

  module Authentication
  end
end

require "stormpath-sdk/auth/username_password_request"
require 'stormpath-sdk/http/utils'
require "stormpath-sdk/http/request"
require "stormpath-sdk/http/response"
require "stormpath-sdk/http/authc/sauthc1_signer"
require "stormpath-sdk/http/http_client_request_executor"
require "stormpath-sdk/auth/basic_login_attempt"
require "stormpath-sdk/auth/authentication_result"
require "stormpath-sdk/auth/basic_authenticator"
