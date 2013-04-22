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
class Stormpath::CollectionResource < Stormpath::Resource

  OFFSET = "offset"
  LIMIT = "limit"
  ITEMS = "items"

  def each(&block)
    current_page.items.each(&block)
  end

  protected

  def offset
    get_property OFFSET
  end

  def limit
    get_property LIMIT
  end

  def current_page

    value = get_property ITEMS
    items = to_resource_array value

    Page.new offset, limit, items
  end

  def to_resource clazz, properties
    self.data_store.instantiate clazz, properties
  end

  private

  class Page

    attr_reader :offset, :limit, :items

    def initialize offset, limit, items
      @offset = offset
      @limit = limit
      @items = items
    end

  end

  def to_resource_array vals

    clazz = item_type
    items = Array.new

    if vals.is_a? Array

      i = 0
      vals.each { |val|
        resource = to_resource clazz, val
        items[i] = resource
        i = i + 1
      }

    end

    items

  end

end
