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
  module Resource
    class Tenant < Stormpath::Resource::Instance
      include Stormpath::Resource::CustomDataStorage

      prop_reader :name, :key, :created_at, :modified_at

      has_many :applications
      has_many :directories
      has_many :organizations
      has_one :custom_data
    end
  end
end
