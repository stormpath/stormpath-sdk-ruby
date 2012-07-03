class DataStore

  String DEFAULT_SERVER_HOST = "api.stormpath.com"

  Integer DEFAULT_API_VERSION = 1

  def initialize(requestExecutor, baseUrl)


    #Assert.notNull(baseUrl, "baseUrl cannot be null");
    #Assert.notNull(requestExecutor, "RequestExecutor cannot be null.");
    @baseUrl = baseUrl;
    @requestExecutor = requestExecutor;
    #@resourceFactory = new DefaultResourceFactory(this);
    #@mapMarshaller = new JacksonMapMarshaller();
  end

  def instantiate(clazz)

  end

  def instantiate(clazz, properties)

  end

  def load(href, clazz)

    if (clazz == Tenant)
      Tenant.new
    end
  end

  def create(parentHref, resource)

  end

  def create(parentHref, resource, returnType)

  end

  def save(resource)

  end

end