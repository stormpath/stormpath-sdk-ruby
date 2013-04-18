require "stormpath-sdk"

describe "Client Application Builder Tests" do

  before(:all) do
    @client_file = 'test/client/client.yml'
    @client_remote_file = 'http://localhost:8081/client.yml'
    @application_href = 'http://localhost:8080/v1/applications/uGBNDZ7TRhm_tahanqvn9A'
    @http_prefix = 'http://'
    @app_href_without_http = '@localhost:8080/v1/applications/uGBNDZ7TRhm_tahanqvn9A'
    @client_builder = Stormpath::ClientBuilder.new.set_base_url 'http://localhost:8080/v1'
    @test_remote_file = false
  end


  it 'Builder should read default properties from YAML file location with application href' do

    result = Stormpath::ClientApplicationBuilder.new(@client_builder).
        set_api_key_file_location(@client_file).
        set_application_href(@application_href).
        build

    result.should be_kind_of Stormpath::ClientApplication

  end

  it 'Builder should create ClientApplication with data from application href with credentials' do

    # getting the properties from file...just to avoid writing them directly
    # in the 'properties' Hash
    yml_obj = YAML::load(File.open @client_file)
    api_key_id_keyword = 'apiKey.id'
    api_key_secret_keyword = 'apiKey.secret'

    # we create the client from this Hash instead of from a file
    properties = {api_key_id_keyword => yml_obj[api_key_id_keyword],
                  api_key_secret_keyword => yml_obj[api_key_secret_keyword]}

    application_href = @http_prefix +
        properties[api_key_id_keyword] +
        ':' +
        properties[api_key_secret_keyword] +
        @app_href_without_http

    result = Stormpath::ClientApplicationBuilder.new(@client_builder).
        set_application_href(application_href).
        build

    result.should be_kind_of Stormpath::ClientApplication

  end

  it 'Builder should read custom complex properties from YAML file locatio with application href' do

    @client_builder = Stormpath::ClientBuilder.new.set_base_url 'http://localhost:8080/v1'
    result = Stormpath::ClientApplicationBuilder.new(@client_builder).
        set_api_key_file_location(@client_file).
        set_api_key_id_property_name('stormpath', 'apiKey', 'id').
        set_api_key_secret_property_name('stormpath', 'apiKey', 'secret').
        set_application_href(@application_href).
        build

    result.should be_kind_of Stormpath::ClientApplication

  end

  it 'Builder should read custom simple properties from YAML file locatio with application href' do

    # getting the properties from file...just to avoid writing them directly
    # in the 'properties' Hash
    yml_obj = YAML::load(File.open @client_file)
    api_key_id_keyword = 'different.apiKey.id'
    api_key_secret_keyword = 'different.apiKey.secret'

    # we create the client from this Hash instead of from a file
    properties = {api_key_id_keyword => yml_obj[api_key_id_keyword],
                  api_key_secret_keyword => yml_obj[api_key_secret_keyword]}

    result = Stormpath::ClientApplicationBuilder.new(@client_builder).
        set_api_key_properties(properties.to_yaml).
        set_api_key_id_property_name(api_key_id_keyword).
        set_api_key_secret_property_name(api_key_secret_keyword).
        set_application_href(@application_href).
        build

    result.should be_kind_of Stormpath::ClientApplication

  end

  it 'Builder should throw exception when creating it with wrong argument' do

    expect { Stormpath::ClientApplicationBuilder.new 'WRONG' }.to raise_error ArgumentError

  end

  it 'Builder should throw exception when trying to build without application href' do

    expect { Stormpath::ClientApplicationBuilder.new(@client_builder).build }.to raise_error ArgumentError

  end

  it 'Builder should throw exception when trying to build with an invalid application href' do

    expect { Stormpath::ClientApplicationBuilder.new(@client_builder).
        set_api_key_file_location(@client_file).
        set_application_href('id:secret@stormpath.com/v1').
        build }.
        to raise_error ArgumentError

  end

end
