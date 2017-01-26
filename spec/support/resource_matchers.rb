RSpec::Matchers.define :be_link do |_expected|
  match do |actual|
    actual.length == 1 && actual['href']
  end
end

RSpec::Matchers.define :be_resource do |_expected|
  match do |actual|
    actual.length > 1 && actual['href'] && !actual['items']
  end
end

RSpec::Matchers.define :be_link_collection do |_expected|
  match do |actual|
    actual['href'] && actual['items'] && actual['items'].all? do |item|
      item && item.length == 1 && item['href']
    end
  end
end

RSpec::Matchers.define :be_resource_collection do |_expected|
  match do |actual|
    actual['href'] && actual['items'] && actual['items'].all? do |item|
      item && item.length > 1 && item['href'] && !item['items']
    end
  end
end

RSpec::Matchers.define :have_stt_in_header do |expected|
  match do |jwt|
    header = JSON.parse(Base64.decode64(jwt.split('.').first))
    header.include?('stt') && header['stt'] == expected
  end
end

RSpec::Matchers.define :be_boolean do
  match do |actual|
    actual == true || actual == false
  end
end
