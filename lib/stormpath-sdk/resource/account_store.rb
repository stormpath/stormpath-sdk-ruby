#
# Copyright 2013 Stormpath, Inc.
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
  module Resource
    class AccountStore < Stormpath::Resource::Instance
      def self.new(*args)
        href = args.first[HREF_PROP_NAME]
        if href =~ /directories/
          Stormpath::Resource::Directory.new(*args)
        elsif href =~ /group/
          Stormpath::Resource::Group.new(*args)
        elsif href =~ /organizations/
          Stormpath::Resource::Organization.new(*args)
        else
          raise 'inappropriate type of an account store'
        end
      end
    end
  end
end
