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
#
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Stormpath

  ##
  # A <a href="http://en.wikipedia.org/wiki/Builder_pattern">Builder design pattern</a> implementation similar to
  # the {@link Stormpath::ClientBuilder}, but focused on single-application interaction with Stormpath.
  # <h2>Description</h2>
  # The {@code ClientBuilder} produces a {@link Stormpath::Client} instance useful for interacting with any aspect
  # of an entire Stormpath Tenant's data space.  However, a software application may only be interested in its own
  # functionality and not the entire Stormpath Tenant data space.
  # <p/>
  # The {@code ClientApplicationBuilder} provides a means to more easily acquiring a single
  # {@link Stormpath::Resource::Application} instance.  From this {@code Application} instance, everything a particular
  # Application needs to perform can be based off of this instance and the wider-scoped concerns of an entire Tenant can be ignored.
  # <h2>Default Usage</h2>
  # <pre>
  # # this can be a file disk or url location as well:
  # location = "/home/jsmith/.stormpath/apiKey.yml"
  #
  # app_href = "https://api.stormpath.com/v1/applications/YOUR_APP_UID_HERE"
  #
  # application = new ClientApplicationBuilder.new.
  #               set_api_key_file_location(location).
  #            <b>set_application_href(app_href)</b>.
  #               build.
  #               application
  # </pre>
  # <p/>
  # After acquiring the {@code Application} instance, you can interact with it to login accounts, reset passwords,
  # etc.
  # <h2>Service Provider Usage with only an Application URL</h2>
  # Some hosting service providers (e.g. like <a href="http://www.heroku.com">Heroku</a>) do not allow easy access to
  # a configuration file and therefore it might be difficult to reference an API Key File.  If you cannot reference an
  # API Key File via the {@code YAML file} or {@code YAML object} or {@code url}
  # {@link ClientBuilder#set_api_key_file_location(String) resource locations}, the Application HREF URL must contain the
  # API Key embedded as the <em><a href="http://en.wikipedia.org/wiki/URI_scheme">user info</a></em> portion of the
  # URL.  For example:
  # <p/>
  # <pre>
  # https://<b>apiKeyId:apiKeySecret@</b>api.stormpath.com/v1/applications/YOUR_APP_UID_HERE
  # </pre>
  # <p/>
  # Notice this is just a normal Application HREF url with the <b>apiKeyId:apiKeySecret@</b> part added in.
  # <p/>
  # Example usage:
  # <pre>
  # appHref = "https://<b>apiKeyId:apiKeySecret@</b>api.stormpath.com/v1/applications/YOUR_APP_UID_HERE";
  #
  # application = new ClientApplicationBuilder.new.
  #            <b>set_application_href(appHref)</b>.
  #               build.
  #               application
  # </pre>
  # <p/>
  # <b>WARNING: ONLY use the embedded API Key technique if you do not have access to {@code YAML file} or
  # {@code YAML object} or {@code url} {@link ClientApplicationBuilder#set_api_key_file_location(String) resource locations}</b>.
  # File based API Key storage is a more secure technique than embedding the key in the URL itself.  Also, again,
  # NEVER share your API Key Secret with <em>anyone</em> (not even co-workers).
  # Stormpath staff will never ask for your API Key Secret.
  #
  # @see #set_api_key_file_location(String)
  # @see #set_application_href(String)
  # @since 0.3.0
  #
  class ClientApplicationBuilder

    include Stormpath::Util::Assert

    DOUBLE_SLASH = "//"

    def initialize client_builder = ClientBuilder.new

      assert_kind_of ClientBuilder, client_builder, 'client_builder must be kind of Stormpath::ClientBuilder'
      @client_builder = client_builder

    end

    # Allows usage of a YAML loadable object (IO object or the result of invoking Object.to_yaml)
    # instead of loading a YAML file via {@link #set_api_key_file_location apiKeyFileLocation} configuration.
    # <p/>
    # The YAML contents and property name overrides function the same as described in the
    # {@link #set_api_key_file_location setApiKeyFileLocation} RDoc.
    #
    # @param properties the YAML object to use to load the API Key ID and Secret.
    # @return this ClientApplicationBuilder instance for method chaining.
    def set_api_key_properties properties

      @client_builder.set_api_key_properties properties
      self

    end

    # Creates an API Key YAML object based on the specified File instead of loading a YAML
    # file via  {@link #set_api_key_file_location apiKeyFileLocation} configuration. This file argument
    # needs to be an IO instance.
    # <p/>
    # The constructed YAML contents and property name overrides function the same as described in the
    # {@link #set_api_key_file_location setApiKeyFileLocation} RDoc.
    # @param file the file to use to construct a YAML object.
    # @return this ClientApplicationBuilder instance for method chaining.
    def set_api_key_file file

      @client_builder.set_api_key_file file
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
    # Assuming you were using these default property names, your {@code ClientApplicationBuilder} usage might look like the
    # following:
    # <pre>
    # location = "/home/jsmith/.stormpath/apiKey.yml";
    #
    # application_href = 'https://<b>apiKeyId:apiKeySecret@</b>api.stormpath.com/v1/applications/YOUR_APP_UID_HERE'
    #
    # application = ClientApplicationBuilder.new.
    #               set_application_href(application_href).
    #               set_api_key_file_location(location).
    #               build.
    #               application
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
    # Your {@code ClientApplicationBuilder} usage would look like the following:
    # <pre>
    # location = "/home/jsmith/.stormpath/apiKey.yml";
    #
    # application = ClientApplicationBuilder.new.
    #               set_api_key_file_location(location).
    #               set_api_key_id_property_name("myStormpathApiKeyId").
    #               set_api_key_secret_property_name("myStormpathApiKeySecret").
    #               set_application_href(application_href).
    #               build.
    #               application
    # </pre>
    #
    # @param location the file or url location of the API Key {@code .yml} file to load when
    #                 constructing the API Key to use for communicating with the Stormpath REST API.
    #
    # @return this ClientApplicationBuilder instance for method chaining.
    #/
    def set_api_key_file_location location

      @client_builder.set_api_key_file_location location
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
    #           ClientApplicationBuilder#set_api_key_id_property_name('stormpath', 'apiKey', 'id')
    #
    # @param api_key_id_property_name the name used to query for the API Key ID from a YAML instance.
    # @return this ClientApplicationBuilder instance for method chaining.
    def set_api_key_id_property_name *api_key_id_property_name

      @client_builder.set_api_key_id_property_name *api_key_id_property_name
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
    #           ClientApplicationBuilder#set_api_key_id_property_name('stormpath', 'apiKey', 'secret')
    #
    # @param api_key_secret_property_name the name used to query for the API Key Secret from a YAML instance.
    # @return this ClientApplicationBuilder instance for method chaining.
    def set_api_key_secret_property_name *api_key_secret_property_name

      @client_builder.set_api_key_secret_property_name *api_key_secret_property_name
      self

    end

    ##
    # Sets the fully qualified Stormpath Application HREF (a URL) to use to acquire the Application instance when
    # {@link #build_application} is called.  See the Class-level RDoc for usage scenarios.
    #
    # @param applicationHref the fully qualified Stormpath Application HREF (a URL) to use to acquire the
    #                        Application instance when {@link #build_application} is called.
    # @return this ClientApplicationBuilder instance for method chaining.
    def set_application_href application_href

      @application_href = application_href
      self

    end

    # Builds a Client and Application wrapper instance based on the configured
    # {@link #set_application_href}. See the Class-level RDoc for usage scenarios.
    #
    # @return a Client and Application wrapper instance based on the configured {@link #set_application_href}.
    def build

      href = !@application_href.nil? ? @application_href.strip : nil

      assert_false (href.nil? or href.empty?),
                   "'application_href' property must be specified when using this builder implementation."


      cleaned_href = href

      at_sigh_index = href.index '@'

      if !at_sigh_index.nil?

        parts = get_href_with_user_info href, at_sigh_index

        cleaned_href = parts[0] + parts[2]

        parts = parts[1].split ':', 2

        api_key_properties = create_api_key_properties parts

        set_api_key_properties api_key_properties

      end #otherwise an apiKey File/YAML/etc for the API Key is required

      client = build_client

      application = client.data_store.get_resource cleaned_href, Stormpath::Application

      ClientApplication.new client, application

    end

    protected

    def build_client
      @client_builder.build
    end

    def get_href_with_user_info href, at_sign_index

      assert_kind_of String, href, 'href must be kind of String'
      assert_kind_of Fixnum, at_sign_index, 'at_sign_index must be kind of Fixnum'

      double_slash_index = href.index DOUBLE_SLASH

      assert_not_nil double_slash_index, 'Invalid application href URL'

      parts = Array.new 3

      parts[0] = href[0..double_slash_index + 1] #up to and including the double slash
      parts[1] = href[double_slash_index + DOUBLE_SLASH.length..at_sign_index - 1] #raw user info
      parts[2] = href[at_sign_index + 1..href.length - 1] #after the @ character

      parts

    end

    def create_api_key_properties pair

      assert_kind_of Array, pair, 'pair must be kind of Array'

      assert_true (pair.length == 2), 'application_href userInfo segment must consist' +
          ' of the following format: apiKeyId:apiKeySecret'

      properties = Hash.new
      properties.store 'apiKey.id', url_decode(pair[0])
      properties.store 'apiKey.secret', url_decode(pair[1])

      properties.to_yaml

    end

    def url_decode url
      URI.decode url
    end
  end

end
