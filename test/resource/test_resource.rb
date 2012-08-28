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

end