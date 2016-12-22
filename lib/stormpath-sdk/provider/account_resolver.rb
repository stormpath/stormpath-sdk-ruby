#
# Copyright 2014 Stormpath, Inc.
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
  module Provider
    class AccountResolver
      include Stormpath::Util::Assert
      attr_reader :data_store, :parent_href, :request

      def initialize(data_store, parent_href, request)
        @data_store = data_store
        @parent_href = parent_href
        @request = request
        assert_not_nil(parent_href, 'parent_href argument must be specified')
        assert_kind_of(AccountRequest, request, "Only #{AccountRequest} instances are supported.")
      end

      def resolve_provider_account
        attempt.provider_data = provider_data
        data_store.create(href, attempt, Stormpath::Provider::AccountResult)
      end

      def provider_data
        @provider_data ||= {}.tap do |body|
          body[request.token_type.to_s.camelize(:lower)] = request.token_value
          body['providerId'] = request.provider
          body['accountStore'] = request_account_store_hash if request.account_store.present?
        end
      end

      private

      def attempt
        @attempt ||= data_store.instantiate(AccountAccess)
      end

      def href
        "#{parent_href}/accounts"
      end

      def request_account_store_hash
        request.account_store.transform_keys { |key| key.to_s.camelize(:lower) }
      end
    end
  end
end
