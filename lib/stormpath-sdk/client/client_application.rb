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

  # A ClientApplication is a simple wrapper around a {@link Stormpath::Client} and
  # {@link Stormpath::Resource::Application} instance, returned from
  # the {@code ClientApplicationBuilder}.{@link Stormpath::ClientApplicationBuilder#build_application}
  # method.
  # @since 0.3.0
  class ClientApplication

    attr_reader :client, :application

    def initialize client, application
      @client = client
      @application = application
    end

  end

end
