module Stormpath

  module Client

    # A <a href="http://en.wikipedia.org/wiki/Builder_pattern">Builder design pattern</a> implementation used to
    # construct {@link Client} instances.
    # <p/>
    # The {@code ClientBuilder} is especially useful for constructing Client instances with Stormpath API Key
    # information loaded from an external {@code .yml} file (or YAML instance) to ensure the API Key secret
    # (password) does not reside in plaintext in code.
    # <p/>
    # Example usage:
    # <pre>
    # String location = "/home/jsmith/.stormpath/apiKey.yml";
    #
    # client = ClientBuilder.new.set_api_key_file_location(location).build()
    # </pre>
    # <p/>
    # You may load files from the filesystem or URLs by specifying the file location.
    #  See {@link #set_api_key_file_location(location)} for more information.
    #
    # @see #set_api_key_file_location(location)
    class ClientBuilder

      include Stormpath::Client
      include Stormpath::Util::Assert

      def initialize
        @apiKeyIdPropertyName = "apiKey.id"
        @apiKeySecretPropertyName = "apiKey.secret"
      end

      # Allows usage of a YAML loadable object (IO object or the result of invoking Object.to_yaml)
      # instead of loading a YAML file via {@link #set_api_key_file_location apiKeyFileLocation} configuration.
      # <p/>
      # The YAML contents and property name overrides function the same as described in the
      # {@link #set_api_key_file_location setApiKeyFileLocation} RDoc.
      #
      # @param properties the YAML object to use to load the API Key ID and Secret.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_properties properties

        @apiKeyProperties = properties
        self

      end

      # Creates an API Key YAML object based on the specified File instead of loading a YAML
      # file via  {@link #set_api_key_file_location apiKeyFileLocation} configuration. This file argument
      # needs to be an IO instance.
      # <p/>
      # The constructed YAML contents and property name overrides function the same as described in the
      # {@link #set_api_key_file_location setApiKeyFileLocation} RDoc.
      # @param file the file to use to construct a YAML object.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_file file
        assert_kind_of IO, file, 'file must be kind of IO'
        @apiKeyFile = file
        self
      end


      # Sets the location of the YAML file to load containing the API Key (Id and secret) used by the
      # Client to communicate with the Stormpath REST API.
      # <p/>
      # You may load files from the filesystem, or URLs just specifying the file location.
      # <h3>File Contents</h3>
      # <p/>
      # When the file is loaded, the following name/value pairs are expected to be present by default:
      # <table>
      #     <tr>
      #         <th>Key</th>
      #         <th>Value</th>
      #     </tr>
      #     <tr>
      #         <td>apiKey.id</td>
      #         <td>An individual account's API Key ID</td>
      #     </tr>
      #     <tr>
      #         <td>apiKey.secret</td>
      #         <td>The API Key Secret (password) that verifies the paired API Key ID.</td>
      #     </tr>
      # </table>
      # <p/>
      # Assuming you were using these default property names, your {@code ClientBuilder} usage might look like the
      # following:
      # <pre>
      # String location = "/home/jsmith/.stormpath/apiKey.yml";
      #
      # client = ClientBuilder.new.set_api_key_file_location(location).build()
      # </pre>
      # <h3>Custom Property Names</h3>
      # If you want to control the property names used in the file, you may configure them via
      # {@link #set_api_key_id_property_name(String) set_api_key_id_property_name} and
      # {@link #set_api_key_secret_property_name(String) set_api_key_secret_property_name}.
      # <p/>
      # For example, if you had a {@code /home/jsmith/.stormpath/apiKey.properties} file with the following
      # name/value pairs:
      # <pre>
      # myStormpathApiKeyId = 'foo'
      # myStormpathApiKeySecret = 'mySuperSecretValue'
      # </pre>
      # Your {@code ClientBuilder} usage would look like the following:
      # <pre>
      # location = "/home/jsmith/.stormpath/apiKey.yml";
      #
      # client =
      #     ClientBuilder.new.
      #     set_api_key_file_location(location).
      #     set_api_key_id_property_name("myStormpathApiKeyId").
      #     set_api_key_secret_property_name("myStormpathApiKeySecret").
      #     build
      # </pre>
      #
      # @param location the file or url location of the API Key {@code .yml} file to load when
      #                 constructing the API Key to use for communicating with the Stormpath REST API.
      #
      # @return the ClientBuilder instance for method chaining.
      #/
      def set_api_key_file_location location
        assert_kind_of String, location, 'location must be kind of String'
        @apiKeyFileLocation = location
        self
      end


      # Sets the name used to query for the API Key ID from a YAML instance.  That is:
      # <pre>
      # apiKeyId = yml.access(<b>apiKeyIdPropertyName</b>)
      # </pre>
      #
      # The Hash#access method searches through the provided path and returns the found value.
      #
      # The <b>apiKeyIdPropertyName</b> key can be as deep as needed, as long as it comes
      # in the exact path order.
      # Example: Having the file 'apiKey.yml' with the following content:
      #
      #           stormpath:
      #             apiKey:
      #             id: myStormpathApiKeyId
      #
      # The method should be called as follows:
      #
      #           ClientBuilder#set_api_key_id_property_name('stormpath', 'apiKey', 'id')
      #
      # @param apiKeyIdPropertyName the name used to query for the API Key ID from a YAML instance.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_id_property_name *apiKeyIdPropertyName

        @apiKeyIdPropertyName = *apiKeyIdPropertyName
        self

      end


      # Sets the name used to query for the API Key Secret from a YAML instance.  That is:
      # <pre>
      # apiKeyId = yml.access(<b>apiKeySecretPropertyName</b>)
      # </pre>
      #
      # The Hash#access method searches through the provided path and returns the found value.
      #
      # The <b>apiKeySecretPropertyName</b> key can be as deep as needed, as long as it comes
      # in the exact path order.
      # Example: Having the file 'apiKey.yml' with the following content:
      #
      #           stormpath:
      #             apiKey:
      #             secret: myStormpathApiKeyId
      #
      # The method should be called as follows:
      #
      #           ClientBuilder#set_api_key_id_property_name('stormpath', 'apiKey', 'secret')
      #
      # @param apiKeySecretPropertyName the name used to query for the API Key Secret from a YAML instance.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_secret_property_name *apiKeySecretPropertyName

        @apiKeySecretPropertyName = *apiKeySecretPropertyName
        self

      end

      # Constructs a new {@link Client} instance based on the ClientBuilder's current configuration state.
      #
      # @return a new {@link Client} instance based on the ClientBuilder's current configuration state.
      #
      def build

        if @apiKeyProperties.nil? or (@apiKeyProperties.respond_to? 'empty?' and @apiKeyProperties.empty?)


          #need to load the properties file

          file = get_available_file

          if file.nil?
            raise ArgumentError, "No API Key file could be found or loaded from a file location.  Please " +
                "configure the 'apiKeyFileLocation' property or alternatively configure a " +
                "YAML loadable instance."
          end

          yaml_obj = YAML::load(file)

        else

          yaml_obj = YAML::load(@apiKeyProperties)

        end

        apiKeyId = get_required_property_value yaml_obj, 'apiKeyId', @apiKeyIdPropertyName

        apiKeySecret = get_required_property_value yaml_obj, 'apiKeySecret', @apiKeySecretPropertyName

        assert_not_nil apiKeyId, 'apiKeyId must not be nil when acquiring it from the YAML object'
        assert_not_nil apiKeySecret, 'apiKeySecret must not be nil when acquiring it from the YAML object'

        apiKey = ApiKey.new apiKeyId, apiKeySecret

        Client.new apiKey, @baseUrl

      end

      def set_base_url baseUrl
        @baseUrl = baseUrl
        self
      end

      private


      def get_property_value yml, propName, separator

        value = yml.access(propName, separator)

        if !value.nil?

          if (value.kind_of? String)

            value = value.strip

          end

          if value.empty?
            value = nil
          end

        end

        value

      end

      def get_required_property_value yml, masterName, *propName


        propNameValue = propName[0]

        separator = '--YAMLKeysSeparator--'
        value = get_property_value(yml, propNameValue.respond_to?('join') ?
            propName[0].join(separator) :
            propNameValue,
                                   separator)

        if value.nil?

          raise ArgumentError, "There is no '" + propName.join(':') + "' property in the " +
              "configured apiKey YAML.  You can either specify that property or " +
              "configure the " + masterName + "PropertyName value on the ClientBuilder to specify a " +
              "custom property name."
        end

        value

      end

      def get_available_file

        if @apiKeyFile
          return @apiKeyFile
        end

        open(@apiKeyFileLocation) { |f| f.read }

      end

    end

  end

end