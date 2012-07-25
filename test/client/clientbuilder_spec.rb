require "stormpath-sdk"

include Stormpath::Client

describe "Client Builder Tests" do

  before(:all) do
    @client_file = 'test/client/client.yml'
    @client_remote_file = 'http://localhost:8081/client.yml'
    @testRemoteFile = false
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
    apiKeyIdKeyword = 'apiKey.id'
    apiKeySecretKeyword = 'apiKey.secret'

    # we create the client from this Hash instead of from a file
    properties = {apiKeyIdKeyword => yml_obj[apiKeyIdKeyword],
                  apiKeySecretKeyword => yml_obj[apiKeySecretKeyword]}

    result = ClientBuilder.new.
        set_api_key_properties(properties.to_yaml).
        build

    result.should be_kind_of Client

  end

  it 'Builder should read custom simple properties from YAML valid object' do

    # getting the properties from file...just to avoid writing them directly
    # in the 'properties' Hash
    yml_obj = YAML::load(File.open @client_file)
    apiKeyIdKeyword = 'different.apiKey.id'
    apiKeySecretKeyword = 'different.apiKey.secret'

    # we create the client from this Hash instead of from a file
    properties = {apiKeyIdKeyword => yml_obj[apiKeyIdKeyword],
                  apiKeySecretKeyword => yml_obj[apiKeySecretKeyword]}

    result = ClientBuilder.new.
        set_api_key_properties(properties.to_yaml).
        set_api_key_id_property_name(apiKeyIdKeyword).
        set_api_key_secret_property_name(apiKeySecretKeyword).
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
    apiKey = 'different.apiKey'
    id = 'different.id'
    secret = 'different.secret'

    # we create the client from this Hash instead of from a file
    data = {id => yml_obj[stormpath][apiKey][id],
            secret => yml_obj[stormpath][apiKey][secret]}
    apiKeyData = {apiKey => data}
    stormpathData = {stormpath => apiKeyData}

    result = ClientBuilder.new.
        set_api_key_properties(stormpathData.to_yaml).
        set_api_key_id_property_name(stormpath, apiKey, id).
        set_api_key_secret_property_name(stormpath, apiKey, secret).
        build

    result.should be_kind_of Client

  end

  it 'Builder should read custom complex properties from YAML file location
      and retrieve a Tenant from the Stormpath REST API' do

    client = ClientBuilder.new.
        set_api_key_file_location(@client_file).
        set_api_key_id_property_name('stormpath', 'apiKey', 'id').
        set_api_key_secret_property_name('stormpath', 'apiKey', 'secret').
        set_base_url('http://localhost:8080/v1').
        build

    result = client.current_tenant

    result.should be_kind_of Tenant

  end

  it 'Builder should read default properties from YAML URL location
      and retrieve a Tenant from the Stormpath REST API' do

    if @testRemoteFile

      client = ClientBuilder.new.
          set_api_key_file_location(@client_remote_file).
          set_base_url('http://localhost:8080/v1').
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
        set_base_url('http://localhost:8080/v1').
        build

    result = client.current_tenant

    result.should be_kind_of Tenant

  end

end