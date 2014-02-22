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
module Stormpath::Resource::Status

  ENABLED = 'ENABLED'
  DISABLED = 'DISABLED'

  def status_hash
    {ENABLED => ENABLED, DISABLED => DISABLED}
  end

  STATUS = "status"

  def status
    value = get_property STATUS
    value.upcase! if value
    value
  end

  def status=(status)
    if status_hash.has_key? status
      set_property STATUS, status_hash[status]
    end
  end

end
