RSpec::Matchers.define :be_link do |expected|
  match do |actual|
    actual.length == 1 && actual['href']
  end
end

RSpec::Matchers.define :be_resource do |expected|
  match do |actual|
    actual.length > 1 && actual['href'] && !actual['items']
  end
end

RSpec::Matchers.define :be_link_collection do |expected|
  match do |actual|
    actual['href'] && actual['items'] && actual['items'].all? do |item|
      item && item.length == 1 && item['href']
    end
  end
end

RSpec::Matchers.define :be_resource_collection do |expected|
  match do |actual|
    actual['href'] && actual['items'] && actual['items'].all? do |item|
      item && item.length > 1 && item['href'] && !item['items']
    end
  end
end
