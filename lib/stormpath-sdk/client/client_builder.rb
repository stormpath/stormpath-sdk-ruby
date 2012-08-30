#
# Copyright 2012 Stormpath, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
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
    # location = "/home/jsmith/.stormpath/apiKey.yml";
    #
    # client = ClientBuilder.new.set_api_key_file_location(location).build
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
        @api_key_id_property_name = "apiKey.id"
        @api_key_secret_property_name = "apiKey.secret"
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

        @api_key_properties = properties
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
        @api_key_file = file
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
      # location = "/home/jsmith/.stormpath/apiKey.yml";
      #
      # client = ClientBuilder.new.set_api_key_file_location(location).build
      # </pre>
      # <h3>Custom Property Names</h3>
      # If you want to control the property names used in the file, you may configure them via
      # {@link #set_api_key_id_property_name(String) set_api_key_id_property_name} and
      # {@link #set_api_key_secret_property_name(String) set_api_key_secret_property_name}.
      # <p/>
      # For example, if you had a {@code /home/jsmith/.stormpath/apiKey.yml} file with the following
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
        @api_key_file_location = location
        self

      end


      # Sets the name used to query for the API Key ID from a YAML instance.  That is:
      # <pre>
      # apiKeyId = yml.access(<b>api_key_id_property_name</b>)
      # </pre>
      #
      # The Hash#access method searches through the provided path and returns the found value.
      #
      # The <b>api_key_id_property_name</b> key can be as deep as needed, as long as it comes
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
      # @param api_key_id_property_name the name used to query for the API Key ID from a YAML instance.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_id_property_name *api_key_id_property_name

        @api_key_id_property_name = *api_key_id_property_name
        self

      end


      # Sets the name used to query for the API Key Secret from a YAML instance.  That is:
      # <pre>
      # apiKeyId = yml.access(<b>api_key_secret_property_name</b>)
      # </pre>
      #
      # The Hash#access method searches through the provided path and returns the found value.
      #
      # The <b>api_key_secret_property_name</b> key can be as deep as needed, as long as it comes
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
      # @param api_key_secret_property_name the name used to query for the API Key Secret from a YAML instance.
      # @return the ClientBuilder instance for method chaining.
      def set_api_key_secret_property_name *api_key_secret_property_name

        @api_key_secret_property_name = *api_key_secret_property_name
        self

      end

      # Constructs a new {@link Client} instance based on the ClientBuilder's current configuration state.
      #
      # @return a new {@link Client} instance based on the ClientBuilder's current configuration state.
      #
      def build

        if @api_key_properties.nil? or (@api_key_properties.respond_to? 'empty?' and @api_key_properties.empty?)


          #need to load the properties file

          file = get_available_file

          assert_not_nil file, "No API Key file could be found or loaded from a file location.  Please " +
              "configure the 'apiKeyFileLocation' property or alternatively configure a " +
              "YAML loadable instance."

          yaml_obj = YAML::load(file)

        else

          yaml_obj = YAML::load(@api_key_properties)

        end

        api_key_id = get_required_property_value yaml_obj, 'api_key_id', @api_key_id_property_name

        api_key_secret = get_required_property_value yaml_obj, 'api_key_secret', @api_key_secret_property_name

        assert_not_nil api_key_id, 'api_key_id must not be nil when acquiring it from the YAML object'
        assert_not_nil api_key_secret, 'api_key_secret must not be nil when acquiring it from the YAML object'

        api_key = ApiKey.new api_key_id, api_key_secret

        Client.new api_key, @base_url

      end

      def set_base_url base_url

        @base_url = base_url
        self

      end

      private


      def get_property_value yml, prop_name, separator

        value = yml.access(prop_name, separator)

        if !value.nil?

          if value.kind_of? String

            value = value.strip

          end

          if value.empty?
            value = nil
          end

        end

        value

      end

      def get_required_property_value yml, masterName, *prop_name


        prop_name_value = prop_name[0]

        separator = '--YAMLKeysSeparator--'
        value = get_property_value(yml, prop_name_value.respond_to?('join') ?
            prop_name[0].join(separator) :
            prop_name_value,
                                   separator)

        assert_not_nil value, "There is no '" + prop_name.join(':') + "' property in the " +
            "configured apiKey YAML.  You can either specify that property or " +
            "configure the #{masterName}_property_name value on the ClientBuilder to specify a " +
            "custom property name."

        value

      end

      def get_available_file

        if @api_key_file
          return @api_key_file
        end

        open(@api_key_file_location) { |f| f.read }

      end

    end

  end

end