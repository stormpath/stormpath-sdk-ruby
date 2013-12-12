class Stormpath::Resource::CustomData < Stormpath::Resource::Instance
  include Stormpath::Resource::Status

  RESERVED_FIELDS = %w( href createdAt modifiedAt meta spMeta spmeta ionmeta ionMeta )
  
  def method_missing(meth, *args, &block)
    if meth =~ /=$/
      property_name = meth.to_s.chomp("=").camelize(:lower)
      if RESERVED_FIELDS.include? property_name
        super(meth, *args, &block)
      else
        set_property property_name, args[0]
      end
    else
      property_name = meth.to_s.camelize(:lower)
      property = get_property property_name 
      property || super(meth, *args, &block)
    end 
  end

  def save
    href = self.properties["href"]
    delete_reserved_fields
    data_store.save self, nil, href
  end

  def delete_reserved_fields
    RESERVED_FIELDS.each do |reserved_method|
        self.properties.delete reserved_method
    end
  end

end
