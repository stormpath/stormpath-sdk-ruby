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

  RESERVED_FIELDS = %w( createdAt modifiedAt meta spMeta spmeta ionmeta ionMeta )

  def get(property_name)
    property_name = property_name.to_s.camelize(:lower)
    property = get_property property_name 
    property
  end

  def put(property_name, property_value)
    unless RESERVED_FIELDS.include? property_name
      set_property property_name, property_value
    end
  end
  
  def save
    if has_removed_properties?
      delete_removed_properties
    end
    if has_new_properties?
      delete_reserved_fields
      data_store.save self
    end
  end

  def remove(name)
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

  def sanitize(properties)
    {}.tap do |sanitized_properties|
      properties.map do |key, value|
        property_name = key.to_s.camelize :lower
        sanitized_properties[property_name] = value
      end
    end
  end

  private
    
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

    def delete_reserved_fields
      RESERVED_FIELDS.each do |reserved_field|
        self.properties.delete reserved_field
      end
    end

end
