#
# Copyright 2012 Stormpath, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Stormpath
  module Authentication
    class BasicAuthenticator
      include Stormpath::Util::Assert

      def initialize(data_store)
        @data_store = data_store
      end

      def authenticate(parent_href, request)
        assert_not_nil parent_href, 'parentHref argument must be specified'
        assert_kind_of UsernamePasswordRequest, request, 'Only UsernamePasswordRequest instances are supported.'

        username = request.principals
        username ||= ''

        password = request.credentials
        pw_string = password.join

        value = username + ':' + pw_string

        value = Base64.encode64(value).tr("\n", '')

        attempt = @data_store.instantiate(BasicLoginAttempt, nil)
        attempt.type = 'basic'
        attempt.value = value

        attempt.account_store = request.account_store if request.account_store

        href = parent_href + '/loginAttempts'

        @data_store.create(href, attempt, AuthenticationResult)
      end
    end
  end
end
