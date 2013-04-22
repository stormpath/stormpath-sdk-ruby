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
class Stormpath::ErrorResource < Stormpath::Resource

  STATUS = "status"
  CODE = "code"
  MESSAGE = "message"
  DEV_MESSAGE = "developerMessage"
  MORE_INFO = "moreInfo"

  def initialize body
    super nil, body
  end

  def status
    get_property STATUS
  end

  def code
    get_property CODE
  end

  def message
    get_property MESSAGE
  end

  def developer_message
    get_property DEV_MESSAGE
  end

  def more_info
    get_property MORE_INFO
  end

end
