require "./lib/stormpath-sdk/version"

Gem::Specification.new do |s|
  s.name = 'stormpath-sdk'
  s.version = Stormpath::VERSION
  s.date = Stormpath::VERSION_DATE
  s.summary = "Stormpath SDK"
  s.description = "Stormpath SDK used to interact with the Stormpath REST API"
  s.authors = ["Stormpath, Inc", "Elder Crisostomo"]
  s.email = 'support@stormpath.com'
  s.homepage = 'https://github.com/stormpath/stormpath-sdk-ruby'
  s.license = 'Apache-2.0'

  s.platform = Gem::Platform::RUBY
  s.require_paths = %w[lib]
  s.files = `git ls-files`.split("\n")

  s.add_dependency('multi_json', '>= 1.3.6')
  s.add_dependency('httpclient', '>= 2.2.5')
  s.add_dependency('uuidtools', '>= 2.1.3')
  if RUBY_VERSION < '2.2.2'
    s.add_dependency('activesupport', '>= 3.2.8', '< 5.0')
  else
    s.add_dependency('activesupport', '>= 3.2.8')
  end
  s.add_dependency('properties-ruby', "~> 0.0.4")
  s.add_dependency('http-cookie', "~> 1.0.2")
  s.add_dependency('java_properties')
  s.add_dependency('jwt', '>= 1.5.0')

  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec', '~> 3.0.0'
  s.add_development_dependency 'guard-rspec', '~> 4.2.10'
  s.add_development_dependency 'rack', '~> 1.4.1'
  s.add_development_dependency 'webmock', '~> 1.17.4'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'pry', '~> 0.9.12.1'
  s.add_development_dependency 'vcr', '~> 2.9.2'
  s.add_development_dependency 'timecop', '~> 0.6.1'
  s.add_development_dependency 'redis', '~> 3.0.4'
  s.add_development_dependency 'listen', '~> 3.0.6'

  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'stormpath-sdk', '--main']
end
