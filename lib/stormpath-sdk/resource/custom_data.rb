class Stormpath::Resource::CustomData < Stormpath::Resource::Instance

  RESERVED_FIELDS = %w( href createdAt modifiedAt meta spMeta spmeta ionmeta ionMeta )

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
    href = properties[HREF_PROP_NAME]
    delete_reserved_fields
    if has_any_keys_to_save
      data_store.save self, nil, href
    end
  end

  def delete(property_name = nil)
    unless new?
      deletion_href = href 
      deletion_href += "/#{property_name.to_s.camelize(:lower)}" if property_name
      data_store.delete self, deletion_href
    end
  end

  private
    
    def delete_reserved_fields
      RESERVED_FIELDS.each do |reserved_field|
        self.properties.delete reserved_field
      end
    end

    def has_any_keys_to_save
      self.properties.size > 0
    end

end
