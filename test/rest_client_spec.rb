require "base64"
require "httpclient"
require "multi_json"


describe 'HTTP Clients test' do

  it 'Testing httpclient' do
    client = HTTPClient.new
    domain = 'http://localhost:8080/v1/applications/A0atUpZARYGApaN5f88O3A'
    user = '4OCDGOGPLVQW8FZO49N5EMZE9'
    password = 'vvEIFpaxzvyiHnhejnzsbnPkXI0CyJE/Yxsrx/wBEGQ'
    client.set_auth(domain, user, password)

    response = client.get_content domain

    p MultiJson.load response

    response.to_s.should be_instance_of String
  end
end