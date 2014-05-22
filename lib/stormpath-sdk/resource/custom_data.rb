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
class Stormpath::Resource::CustomData < Stormpath::Resource::Instance
  include Stormpath::Resource::CustomDataHashMethods

  def [](property_name)
    get_property property_name, ignore_camelcasing: true
  end

  def []=(property_name, property_value)
    set_property property_name, property_value, ignore_camelcasing: true
  end
  
  def save
    if has_removed_properties?
      delete_removed_properties
    end
    if has_new_properties?
      super
    end
  end

  def delete(name = nil)
    if name.nil?
      @properties = { HREF_PROP_NAME => @properties[HREF_PROP_NAME] }
      @dirty_properties.clear
      @deleted_properties.clear
      return super()
    end

    @write_lock.lock
    property_name = name.to_s
    begin
      @properties.delete(property_name)
      @dirty_properties.delete(property_name)
      @deleted_properties << property_name
      @dirty = true
    ensure
      @write_lock.unlock
    end
  end

  private

    def sanitize(properties)
      {}.tap do |sanitized_properties|
        properties.map do |key, value|
          property_name = key.to_s
          sanitized_properties[property_name] = value
        end
      end
    end

    def has_removed_properties?
      @read_lock.lock
      begin
        !@deleted_properties.empty?
      ensure
        @read_lock.unlock
      end
    end

    def has_new_properties?
      @read_lock.lock
      begin
        !@dirty_properties.empty?
      ensure
        @read_lock.unlock
      end
    end

    def delete_removed_properties
      @deleted_properties.each do |deleted_property_name|
        data_store.delete self, deleted_property_name
      end
    end

end
