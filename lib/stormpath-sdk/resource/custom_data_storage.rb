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
module Stormpath::Resource::CustomDataStorage
  extend ActiveSupport::Concern

  CUSTOM_DATA = "custom_data"

  included do

    def save
      apply_custom_data_updates_if_necessary
      super
    end

    def apply_custom_data_updates_if_necessary
      if custom_data.send :has_removed_properties?
        custom_data.send :delete_removed_properties
      end
      if custom_data.send :has_new_properties?
        self.set_property CUSTOM_DATA, custom_data.dirty_properties
      end
    end

  end

end
