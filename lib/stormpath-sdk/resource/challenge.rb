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
class Stormpath::Resource::Challenge < Stormpath::Resource::Instance
  prop_accessor :message
  prop_reader :status, :created_at, :modified_at

  belongs_to :factor
  belongs_to :account

  def validate(code)
    data_store.execute_raw_request href, { code: code }, Stormpath::Resource::Challenge
  end
end
