class Stormpath::Resource::Expansion
  attr_reader :query

  def initialize *names
    @query = {}
    @properties = {}

    names.each { |name| add_property name }
  end

  def add_property name, options = {}
    @properties[name] = if options[:offset] || options[:limit]
      pagination = []
      pagination.push("offset:#{options[:offset]}") if options[:offset]
      pagination.push("limit:#{options[:limit]}") if options[:limit]

      "#{name}(#{pagination.join(',')})"
    else
      name
    end
  end

  def to_query
    if @properties.any?
      { expand: @properties.values.join(',') }
    end
  end
end
