require 'stormpath-sdk'

require 'webmock/rspec'

WebMock.allow_net_connect!

def destroy_all_stormpath_test_resources api_key
  client = Stormpath::Client.new({
    api_key: api_key
  })

  tenant = client.current_tenant

  directories = tenant.get_directories

  directories.each do |dir|
    dir.delete if dir.get_name.start_with? 'TestDirectory'
  end

  applications = tenant.get_applications

  applications.each do |app|
    app.delete if app.get_name.start_with? 'TestApplication'
  end
end
