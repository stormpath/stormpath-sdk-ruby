class TestResource < Stormpath::Resource::Resource

  def get_name
    get_property 'name'
  end

  def set_name name
    set_property 'name', name
  end

  def get_description
    get_property 'description'
  end

  def set_description description
    set_property 'description', description
  end

  def set_password password
    set_property 'password', password
  end

  protected
  def printable_property? property_name
    'password' != property_name
  end

end