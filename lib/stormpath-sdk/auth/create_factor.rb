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
      attr_reader :client, :account, :type, :phone, :challenge

      def initialize(client, account, type, options = {})
        @client = client
        @account = account
        @type = type
        @phone = options[:phone]
        @challenge = options[:challenge] || nil
      end

      def save
        data_store.execute_raw_request(href, resource, Stormpath::Resource::Factor)
      end

      private

      def href
        "#{account.href}/factors#{'?challenge=true' if challenge}"
      end

      def resource
        body = {}
        body[:type] = type
        body[:phone] = { number: phone[:number] }
        body[:phone][:name] = phone[:name]
        body[:phone][:description] = phone[:description]
        body[:challenge] = { message: "#{challenge[:message]} ${code}" } if challenge
        body
      end
    end
  end
end
