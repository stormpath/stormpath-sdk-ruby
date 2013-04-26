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
class Stormpath::Error < RuntimeError

  def initialize error = nil
    super !error.nil? ? error.message : ''
    @error = error
  end

  def status
    !@error.nil? ? @error.status : -1
  end

  def code
    !@error.nil? ? @error.code : -1
  end

  def developer_message
    !@error.nil? ? @error.developer_message : nil
  end

  def more_info
    !@error.nil? ? @error.more_info : nil
  end

end
