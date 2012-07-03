class ApiKey

  attr_accessor :id, :secret

  def initialize(id, secret)
    @id = id
    @secret = secret
  end
end