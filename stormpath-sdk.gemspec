require "./lib/stormpath-sdk/version"

Gem::Specification.new do |s|
  s.name = 'stormpath-sdk'
  s.version = Stormpath::VERSION
  s.date = Stormpath::VERSION_DATE
  s.summary = "Stormpath SDK"
  s.description = "Stormpath SDK used to interact with the Stormpath REST API"
  s.authors = ["Elder Crisostomo"]
  s.email = 'elder@stormpath.com'
  s.homepage = 'https://github.com/stormpath/stormpath-sdk-ruby'

  s.platform = Gem::Platform::RUBY
  s.require_paths = %w[lib]
  s.files = `git ls-files`.split("\n")
  s.test_files = Dir['test/**/*.rb']

  s.add_dependency('multi_json', '>= 1.3.6')
  s.add_dependency('httpclient', '>= 2.2.5')
  s.add_dependency('uuidtools', '>= 2.1.3')
  s.add_dependency('activesupport', '>= 3.2.8')
  s.add_dependency('properties-ruby', "~> 0.0.4")
  s.add_dependency('java_properties')

  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec-core', '~> 2.14rc1'
  s.add_development_dependency 'rspec-expectations', '~> 2.14rc1'
  s.add_development_dependency 'rspec-mocks', '~> 2.14rc1'
  s.add_development_dependency 'rack', '~> 1.4.1'
  s.add_development_dependency 'webmock', '~> 1.11.0'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'pry', '~> 0.9.12.1'
  s.add_development_dependency 'pry-debugger', '~> 0.2.2'
  s.add_development_dependency 'pry-stack_explorer', '~> 0.4.9'
  s.add_development_dependency 'vcr', '~> 2.4.0'
  s.add_development_dependency 'timecop', '~> 0.6.1'
  s.add_development_dependency 'redis', '~> 3.0.4'

  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'stormpath-sdk', '--main']
end
