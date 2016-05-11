require 'bundler/gem_tasks'
require 'rubygems'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'stormpath-sdk'
require './support/api'


spec = eval(File.read('stormpath-sdk.gemspec'))

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
end

RSpec::Core::RakeTask.new do |t|
  t.pattern = '**/*_spec.rb'
  t.rspec_opts = ['-c']
end

task :default => :spec

namespace :api do
  task :clean do
    Stormpath::Support::Api.destroy_resources(
      ENV['STORMPATH_SDK_TEST_API_KEY_ID'],
      ENV['STORMPATH_SDK_TEST_API_KEY_SECRET'],
      ENV['STORMPATH_SDK_TEST_APPLICATION_URL'],
      ENV['STORMPATH_SDK_TEST_DIRECTORY_URL'],
      ENV['STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL']
    )
  end
end
