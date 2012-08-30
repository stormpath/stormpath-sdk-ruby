require "stormpath-sdk"

include Stormpath::Client

describe "Client Builder Tests" do

  before(:all) do
    @client_file = 'test/client/client.yml'
    @client_remote_file = 'http://localhost:8081/client.yml'
    @test_remote_file = false
  end


  it 'Builder should read default properties from YAML file location' do

    result = ClientBuilder.new.
        set_api_key_file_location(@client_file).
        build

    result.should be_kind_of Client

  end

  it 'Builder should read default properties from YAML FILE object' do

    result = ClientBuilder.new.
        set_api_key_file(File.open(@client_file)).
        build

    result.should be_kind_of Client

  end

  it 'Builder should read custom simple properties from YAML file location' do

    result = ClientBuilder.new.
        set_api_key_file_location(@client_file).
        set_api_key_id_property_name('different.apiKey.id').
        set_api_key_secret_property_name('different.apiKey.secret').
        build

    result.should be_kind_of Client

  end

  it 'Builder should read default properties from YAML valid object' do

    # getting the properties from file...just to avoid writing them directly
    # in the 'properties' Hash
    yml_obj = YAML::load(File.open @client_file)
    api_key_id_keyword = 'apiKey.id'
    api_key_secret_keyword = 'apiKey.secret'

    # we create the client from this Hash instead of from a file
    properties = {api_key_id_keyword => yml_obj[api_key_id_keyword],
                  api_key_secret_keyword => yml_obj[api_key_secret_keyword]}

    result = ClientBuilder.new.
        set_api_key_properties(properties.to_yaml).
        build

    result.should be_kind_of Client

  end

  it 'Builder should read custom simple properties from YAML valid object' do

    # getting the properties from file...just to avoid writing them directly
    # in the 'properties' Hash
    yml_obj = YAML::load(File.open @client_file)
    api_key_id_keyword = 'different.apiKey.id'
    api_key_secret_keyword = 'different.apiKey.secret'

    # we create the client from this Hash instead of from a file
    properties = {api_key_id_keyword => yml_obj[api_key_id_keyword],
                  api_key_secret_keyword => yml_obj[api_key_secret_keyword]}

    result = ClientBuilder.new.
        set_api_key_properties(properties.to_yaml).
        set_api_key_id_property_name(api_key_id_keyword).
        set_api_key_secret_property_name(api_key_secret_keyword).
        build

    result.should be_kind_of Client

  end

  it 'Builder should read custom complex properties from YAML file location' do

    result = ClientBuilder.new.
        set_api_key_file_location(@client_file).
        set_api_key_id_property_name('stormpath', 'apiKey', 'id').
        set_api_key_secret_property_name('stormpath', 'apiKey', 'secret').
        build

    result.should be_kind_of Client

  end

  it 'Builder should read custom complex properties from YAML valid object' do

    # getting the properties from file...just to avoid writing them directly
    # in the 'properties' Hash
    yml_obj = YAML::load(File.open @client_file)
    stormpath = 'different.stormpath'
    api_key = 'different.apiKey'
    id = 'different.id'
    secret = 'different.secret'

    # we create the client from this Hash instead of from a file
    data = {id => yml_obj[stormpath][api_key][id],
            secret => yml_obj[stormpath][api_key][secret]}
    api_key_data = {api_key => data}
    stormpath_data = {stormpath => api_key_data}

    result = ClientBuilder.new.
        set_api_key_properties(stormpath_data.to_yaml).
        set_api_key_id_property_name(stormpath, api_key, id).
        set_api_key_secret_property_name(stormpath, api_key, secret).
        build

    result.should be_kind_of Client

  end

  it 'Builder should read custom complex properties from YAML file location
      and retrieve a Tenant from the Stormpath REST API' do

    client = ClientBuilder.new.
        set_api_key_file_location(@client_file).
        set_api_key_id_property_name('stormpath', 'apiKey', 'id').
        set_api_key_secret_property_name('stormpath', 'apiKey', 'secret').
        #set_base_url('http://localhost:8080/v1').
        build

    result = client.current_tenant

    result.should be_kind_of Tenant

  end

  it 'Builder should read default properties from YAML URL location
      and retrieve a Tenant from the Stormpath REST API' do

    if @test_remote_file

      client = ClientBuilder.new.
          set_api_key_file_location(@client_remote_file).
          #set_base_url('http://localhost:8080/v1').
          build

      result = client.current_tenant

      result.should be_kind_of Tenant
    end


  end

  it 'Builder should read custom complex properties from YAML file URL location
      and retrieve a Tenant from the Stormpath REST API' do

    client = ClientBuilder.new.
        set_api_key_file_location(@client_remote_file).
        set_api_key_id_property_name('stormpath', 'apiKey', 'id').
        set_api_key_secret_property_name('stormpath', 'apiKey', 'secret').
        #set_base_url('http://localhost:8080/v1').
        build

    result = client.current_tenant

    result.should be_kind_of Tenant

  end

end