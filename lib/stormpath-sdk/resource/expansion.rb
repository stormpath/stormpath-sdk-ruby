class Stormpath::Resource::Expansion
  attr_reader :query

  def initialize(names=nil)
    @query = Hash.new
    @properties = Hash.new

    names = Array.wrap(names) || []
    names.each { |n| add_property(n) } if names and !names.empty?
  end

  def add_property(name, offset=nil, limit=nil)
    s = name.to_s #accept a symbol or a string

    if offset or limit
      pagination = []
      pagination.push("offset:#{offset}") unless offset.nil?
      pagination.push("limit:#{limit}") unless limit.nil?

      s = "#{s}(#{pagination.join(',')})"
    end

    @properties[name] = s
  end

  def to_query()
    @properties.empty? ? nil : { 'expand' => @properties.values.join(',') }
  end
end
