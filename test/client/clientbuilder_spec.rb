require "stormpath-sdk"

describe "Client Builder Tests" do


  it 'Builder should read from YAML file' do

    result = YAML::load('hello:world'.to_yaml)

    p result['hello']


  end

end