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
    class CreateFactor < Stormpath::Resource::Base
      attr_reader :client, :account, :type, :phone, :challenge, :custom_options

      def initialize(client, account, type, options = {})
        @client = client
        @account = account
        @type = determine_type(type)
        @phone = options[:phone] || nil
        @challenge = options[:challenge] || nil
        @custom_options = options[:custom_options] || nil
      end

      def save
        data_store.execute_raw_request(href, resource, Stormpath::Resource::Factor)
      end

      private

      def href
        "#{account.href}/factors#{'?challenge=true' if challenge}"
      end

      def resource
        {}.tap do |body|
          body[:type] = type
          body[:phone] = phone if phone
          body[:challenge] = { message: "#{challenge[:message]} ${code}" } if challenge
          add_custom_options(body)
        end
      end

      def determine_type(type)
        raise Stormpath::Error unless type == :sms || type == :google_authenticator
        type.to_s.sub('_', '-')
      end

      def add_custom_options(body)
        if custom_options
          body[:accountName] = custom_options[:account_name] if custom_options[:account_name]
          body[:issuer] = custom_options[:issuer] if custom_options[:issuer]
          body[:status] = custom_options[:status] if custom_options[:status]
        end
        body
      end
    end
  end
end
