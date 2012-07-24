module Stormpath

  module Client

    class ClientBuilder

      include Stormpath::Client
      include Stormpath::Util::Assert

      def initialize
        @apiKeyIdPropertyName = "apiKey.id"
        @apiKeySecretPropertyName = "apiKey.secret"
      end

      # Allows usage of a YAML loadable object instead of loading a YAML file via
      # {@link #set_api_key_file_location apiKeyFileLocation} configuration.
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
      # file via  {@link #set_api_key_file_location apiKeyFileLocation} configuration.
      # <p/>
      # The constructed YAML contents and property name overrides function the same as described in the
      # {@link #set_api_key_file_location setApiKeyFileLocation} RDoc.
      # @param file the file to use to construct a YAML object.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_file file
        @apiKeyFile = file
        self
      end


      # Sets the location of the YAML file to load containing the API Key (Id and secret) used by the
      # Client to communicate with the Stormpath REST API.
      # <p/>
      # You may load files from the filesystem, or URLs by prefixing the location path with
      # {@code file:} or {@code url:} respectively.  If no prefix is found, {@code file:}
      # is assumed by default.
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
      # String location = "/home/jsmith/.stormpath/apiKey.properties";
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
      # location = "/home/jsmith/.stormpath/apiKey.properties";
      #
      # client =
      #     ClientBuilder.new
      #     .set_api_key_file_location(location)
      #     .set_api_key_id_property_name("myStormpathApiKeyId")
      #     .set_api_key_secret_property_name("myStormpathApiKeySecret")
      #     .build()
      # </pre>
      #
      # @param location the file or url location of the API Key {@code .properties} file to load when
      #                 constructing the API Key to use for communicating with the Stormpath REST API.
      #
      # @return the ClientBuilder instance for method chaining.
      #/
      def set_api_key_file_location location
        @apiKeyFileLocation = location
        self
      end


      # Sets the name used to query for the API Key ID from a YAML instance.  That is:
      # <pre>
      # apiKeyId = yml[<b>apiKeyIdPropertyName</b>]
      # </pre>
      #
      # @param apiKeyIdPropertyName the name used to query for the API Key ID from a YAML instance.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_id_property_name apiKeyIdPropertyName

        @apiKeyIdPropertyName = apiKeyIdPropertyName
        self

      end


      # Sets the name used to query for the API Key Secret from a YAML instance.  That is:
      # <pre>
      # apiKeyId = yml[<b>apiKeySecretPropertyName</b>]
      # </pre>
      #
      # @param apiKeyIdPropertyName the name used to query for the API Key ID from a YAML instance.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_secret_property_name apiKeySecretPropertyName

        @apiKeySecretPropertyName = apiKeySecretPropertyName

      end

      # Constructs a new {@link Client} instance based on the ClientBuilder's current configuration state.
      #
      # @return a new {@link Client} instance based on the ClientBuilder's current configuration state.
      #
      def build

        yaml_obj = nil

        if @apiKeyProperties.nil? or (@apiKeyProperties.respond_to? 'empty?' and @apiKeyProperties.empty?)


          #need to load the properties file

          file = get_available_file

          if file.nil?
            raise ArgumentError "No API Key file could be found or loaded from a file location.  Please " +
                                    "configure the 'apiKeyFileLocation' property or alternatively configure a " +
                                    "YAML loadable instance."
          end

          yaml_obj = YAML::load(file)

        end

        apiKeyId = get_required_property_value yaml_obj, @apiKeyIdPropertyName, 'apiKeyId'

        apiKeySecret = get_required_property_value yaml_obj, @apiKeySecretPropertyName, 'apiKeySecret'

        assert_not_nil apiKeyId
        assert_not_nil apiKeySecret

        apiKey = ApiKey.new apiKeyId, apiKeySecret

        Client.new apiKey, @baseUrl

      end

      def set_base_url baseUrl
        @baseUrl = baseUrl
        self
      end

      private


      def get_property_value yml, propName

        value = yml[propName]

        if !value.nil?

          value = value.strip

          if value.empty?
            value = nil
          end

        end

        value

      end

      def get_required_property_value yml, propName, masterName

        value = get_property_value yml, propName

        if value.nil?

          raise ArgumentError "There is no '" + propName + "' property in the " +
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


        File.open(@apiKeyFileLocation)

      end

    end

  end

end