[![Build Status](https://api.travis-ci.org/stormpath/stormpath-sdk-ruby.png?branch=master,development)](https://travis-ci.org/stormpath/stormpath-sdk-ruby)
[![Code Climate](https://codeclimate.com/github/stormpath/stormpath-sdk-ruby/badges/gpa.svg)](https://codeclimate.com/github/stormpath/stormpath-sdk-ruby)

# Stormpath Ruby SDK

Stormpath is the first easy, secure user management and authentication service for developers.
This is the Ruby SDK to ease integration of its features with any Ruby language based
application.

## Install

```sh
$ gem install stormpath-sdk --pre
```

## Provision Your Stormpath Account

If you have not already done so, register as a developer on
[Stormpath][stormpath] and set up your API credentials and resources:

1. Create a [Stormpath][stormpath] developer account and
   [create your API Keys][create-api-keys] downloading the
   <code>apiKey.properties</code> file into a <code>.stormpath</code>
   folder under your local home directory.

1. Through the [Stormpath Admin UI][stormpath-admin-login], create yourself
   an [Application Resource][concepts]. On the Create New Application
   screen, make sure the "Create a new directory with this application" box
   is checked. This will provision a [Directory Resource][concepts] along
   with your new Application Resource and link the Directory to the
   Application as a [Login Source][concepts]. This will allow users
   associated with that Directory Resource to authenticate and have access
   to that Application Resource.

   It is important to note that although your developer account comes with
   a built-in Application Resource (called "Stormpath") - you will still
   need to provision a separate Application Resource.

1. Take note of the _REST URL_ of the Application you just created. Your
   web application will communicate with the Stormpath API in the context
   of this one Application Resource (operations such as: user-creation,
   authentication, etc.)

## Getting Started

1.  **Require the Stormpath Ruby SDK**

    ```ruby
    require 'stormpath-sdk'
    ```

1.  **Create a client** using the API key properties file

    ```ruby
    client = Stormpath::Client.new api_key_file_location: File.join(ENV['HOME'], '.stormpath', 'apiKey.properties')
    ```

1.  **List all your applications and directories**

    ```ruby
    client.applications.each do |application|
      p "Application: #{application.name}"
    end

    client.directories.each do |directory|
      p "Directory: #{directory.name}"
    end
    ```

1.  **Get access to the specific application and directory** using the
    URLs you acquired above.

    ```ruby
    application = client.applications.get application_url

    directory = client.directories.get directory_url
    ```

1.  **Create an account for a user** on the directory.

    ```ruby
    account = directory.accounts.create({
      given_name: 'John',
      surname: 'Smith',
      email: 'john.smith@example.com',
      username: 'johnsmith',
      password: '4P@$$w0rd!'
    })
    ```

1.  **Update an account**

    ```ruby
    account.given_name = 'Johnathan'
    account.middle_name = 'A.'
    account.save
    ```

1.  **Authenticate the Account** for use with an application:

    ```ruby
    auth_request =
      Stormpath::Authentication::UsernamePasswordRequest.new 'johnsmith', '4P@$$w0rd!'

    begin
      auth_result = application.authenticate_account auth_request
      account = auth_result.account
    rescue Stormpath::Error => e
      #If credentials are invalid or account doesn't exist
    end
    ```

1.  **Send a password reset request**

    ```ruby
    application.send_password_reset_email 'john.smith@example.com'
    ```

1.  **Create a group** in a directory

    ```ruby
    directory.groups.create name: 'Admins'
    ```

1.  **Add the account to the group**

    ```ruby
    group.add_account account
    ```

1. **Check for account inclusion in group** by reloading the account

    ```ruby
    account = client.accounts.get account.href
    is_admin = account.groups.any? { |group| group.name == 'Admins' }
    ```

## Common Uses

### Creating a client

All Stormpath features are accessed through a
<code>Stormpath::Client</code> instance, or a resource
created from one. A client needs an API key (made up of an _id_ and a
_secret_) from your Stormpath developer account to manage resources
on that account. That API key can be specified any number of ways
in the hash of values passed on Client initialization:

* The location of API key properties file:

  ```ruby
  client = Stormpath::Client.new
    api_key_file_location: '/some/path/to/apiKey.properties'
  ```

  You can even identify the names of the properties to use as the API
  key id and secret. For example, suppose your properties was:

  ```
  foo=APIKEYID
  bar=APIKEYSECRET
  ```

  You could load it with the following:

  ```ruby
  client = Stormpath::Client.new
    api_key_file_location: '/some/path/to/apiKey.properties',
    api_key_id_property_name: 'foo',
    api_key_secret_property_name: 'bar'
  ```

* Passing in a Stormpath::APIKey instance:

  ```ruby
  api_key = Stormpath::ApiKey.new api_id, api_secret
  client = Stormpath::Client.new api_key: api_key
  ```

* By explicitly setting the API key id and secret:

  ```ruby
  client = Stormpath::Client.new
    api_key: { id: api_id, secret: api_secret }
  ```

* By passing a composite application url to `Application.load`:

  ```ruby
  composite_url = "http://#{api_key_id}:#{api_key_secret}@api.stormpath.com/v1/applications/#{application_id}"

  application = Stormpath::Resource::Application.load composite_url
  client = application.client
  ```

### Accessing Resources

Most of the work you do with Stormpath is done through the applications
and directories you have registered. You use the client to access them
with their REST URL:

```ruby
application = client.applications.get application_url

directory = client.directories.get directory_url
```

The <code>applications</code> and <code>directories</code> property on a
client instance are also <code>Enumerable</code> allowing you to iterate
and scan for resources via that interface.

Additional resources are <code>accounts</code>, <code>groups</code>,
<code>group_membership</code>, and the single reference to your
<code>tenant</code>.

### Creating Resources

Applications and directories can be created directly off the client.

```ruby
application = client.applications.create name: 'foo', description: 'bar'

directory = client.directories.create name: 'foo', description: 'bar'
```

### Collections
#### Search

Resource collections can be searched by a general query string or by attribute.

Passing a string to the search method will filter by any attribute on the collection:

```ruby
client.applications.search 'foo'
```

To search a specific attribute or attributes, pass a hash:

```ruby
client.applications.search name: 'foo', description: 'bar'
```

#### Pagination

Collections can be paginated using chainable Arel-like methods. <code>offset</code> is the zero-based starting index in the entire collection of the first item to return. Default is 0. <code>limit</code> is the maximum number of collection items to return for a single request. Minimum value is 1. Maximum value is 100. Default is 25.

```ruby
client.applications.offset(10).limit(100).each do |application|
  # do something
end
```

#### Order

Collections can be ordered. In the following example, a paginated collection is ordered.

```ruby
client.applications.offset(10).limit(100).order('name asc,description desc')
```

#### Entity Expansion

A resource's children can be eager loaded by passing the entity expansion object as the second argument to a call to <code>get</code>.

```ruby
expansion = Stormpath::Resource::Expansion.new 'groups', 'group_memberships'
client.accounts.get account.href, expansion
```

<code>limit</code> and <code>offset</code> can be specified for each child resource by calling <code>add_property</code>.

```ruby
expansion = Stormpath::Resource::Expansion.new
expansion.add_property 'groups', offset: 5, limit: 10

client.accounts.get account.href, expansion
```

### ID Site

ID Site is a set of hosted and pre-built user interface screens that easily add authentication to your application. ID Site can be accessed via your own custom domain like id.mydomain.com and shared across multiple applications to create centralized authentication if needed. To use ID Site an url needs to be generated which contains JWT token as a parameter.

#### ID Site Login

In order to use ID Site an url needs to be generated. You also need to redirect to the generated url. You can call create_id_site_url which is on application object. For example if you are using sinatra the code would look something like this:

```ruby
get ‘login’ do
  redirect application.create_id_site_url callback_uri: “#{callback_uri}”
end
```

The application will be an instance of your application. callback_uri is a url with which you want to handle the ID Site information, this url also needs to be set in the Stormpath’s dashboard on [ID Site settings page](https://api.stormpath.com/ui2/index.html#/id-site) as Authorized Redirect URLs.

##### Using ID Site for [multitenancy][id-site-multitenancy]

When a user wants to login to your application, you may want to specify an organization for the user to login to. Stormpath ID Site is configurable to support multitenancy with Organization resources

```ruby
application.create_id_site_url({
  callback_uri: 'https://trooperapp.com/callback',
  organization_name_key: 'stormtrooper',
  show_organization_field: true
});
```

##### Using Subdomains 

In some cases, you may want to show the organization that the user is logging into as a subdomain instead of an form field. To configure this, you need to use a [wildcard certificate][wildcard-certificate] when setting up your [custom domain with ID Site][custom-domain-with-id-site]. Otherwise, the Stormpath infrastructure will cause browser SSL errors.

Once a wildcard certificate is configured on your domain, you can tell ID Site to use a subdomain to represent the organization:

```ruby
application.create_id_site_url({
  callback_uri: 'https://trooperapp.com/callback',
  organization_name_key: 'stormtrooper',
  use_subdomain: true
});
```

##### Specifying the Organization

In the case where you are using a subdomain to designate the organization, you can tell ID Site which organization the user is logging into to.

```ruby
application.create_id_site_url({
  callback_uri: 'https://trooperapp.com/callback',
  organization_name_key: 'stormtrooper',
  show_organization_field: true
})
```

#### Handle ID Site Callback

For any request you make for ID Site, you need to specify a callback uri. To parse the information from the servers response and to decode the data from the JWT token you need to call the handle_id_site_callback method and pass the Request URI.

For example in your sinatra app this would look something like this:

```ruby
app.get ‘/callback' do
  user_data = application.handle_id_site_callback(request.url)
end
```

> NOTE:
> A JWT Response Token can only be used once. This is to prevent replay attacks. It will also only be valid for a total of 60 seconds. After which time, You will need to restart the workflow you were in.

#### Other ID Site Options

There are a few other methods that you will need to concern yourself with when using ID Site. Logging out a User, Registering a User, and a User who has forgotten their password. These methods will use the same information from the login method but a few more items will need to be passed into the array. For example if you have a sinatra application.

##### Logging Out a User
```ruby
app.get ‘/logout' do
  user_data = application.handle_id_site_callback(request.url)
  redirect application.create_id_site_url callback_uri: “#{callback_uri}”, logout: true
end
```

##### Registering a User
```ruby
app.get ‘/register' do
  user_data = application.handle_id_site_callback(request.url)
  redirect application.create_id_site_url callback_uri: “#{callback_uri}”, path: ‘/#/register'
end
```

##### Forgot Link
```ruby
app.get ‘/forgot' do
  user_data = application.handle_id_site_callback(request.url)
  redirect application.create_id_site_url callback_uri: “#{callback_uri}”, path: ‘/#/forgot'
end
```

Again, with all these methods, You will want your application to link to an internal page where the JWT is created at that time. Without doing this, a user will only have 60 seconds to click on the link before the JWT expires.

> NOTE:
> A JWT will expire after 60 seconds of creation.

#### Exchange ID Site token for a Stormpath Access Token
After the user has been authenticated via ID Site, a developer may want to control their authorization with an OAuth 2.0 Token. 
This is done by passing the JWT similar to the way we passed the user’s credentials as described in [Generating an OAuth 2.0 Access Token][generate-oauth-access-token]. 
The difference is that instead of using the password grant type and passing credentials, we will use the id_site_token type and pass the JWT we got from the ID Site
more info [here][exchange-id-site-token].

To exchange ID Site token for the oauth token use the following snippet
```ruby
grant_request = Stormpath::Oauth::IdSiteGrantRequest.new jwt_token
response = application.authenticate_oauth grant_request
```

### Registering Accounts

Accounts are created on a directory instance. They can be created in two
ways:

* With the <code>create_account</code> method:

  ```ruby
  account = directory.create_account({
    given_name: 'John',
    surname: 'Smith',
    email: 'john.smith@example.com',
    username: 'johnsmith',
    password: '4P@$$w0rd!'
  })
  ```

  This metod can take an additional flag to indicate if the account
  can skip any registration workflow configured on the directory.

  ```ruby
  ## Will skip workflow, if any
  account = directory.create_account account_props, false
  ```

* Creating it directly on the <code>accounts</code> collection property
  on the directory:

  ```ruby
  account = directory.accounts.create({
    given_name: 'John',
    surname: 'Smith',
    email: 'john.smith@example.com',
    username: 'johnsmith',
    password: '4P@$$w0rd!'
  })
  ```

Both these methods can take either a <code>Hash</code> of the account
properties, or a <code>Stormpath::Account</code>.

If the directory has been configured with an email verification workflow
and a non-Stormpath URL, you have to pass the verification token sent to
the URL in a <code>sptoken</code> query parameter back to Stormpath to
complete the workflow. This is done through the
<code>verify_email_token</code> on the <code>accounts</code> collection.

For example, suppose you have a Sinatra application
that is handling the email verification at the path
<code>/users/verify</code>. You could use the following code:

```ruby
get '/users/verify' do
  token = params[:sptoken]
  account = client.accounts.verify_email_token token
  #proceed to update session, display account, etc
end
```

#### Create an Account with an Existing Password Hash

If you are moving from an existing user repository to Stormpath, you may have existing password hashes that you want to reuse to provide a seamless upgrade path for your end users.
More info about this feature can be found [here][mcf-hash-password-doc]

Example of creating an account with existing SHA-512 password hash. For details on other hashing algorithms chech the [documentation][stormpaht-hash-algorithm]

directory.accounts.create({
  username: "jlucpicard",
  email: "captain@enterprise.com",
  given_name: "Jean-Luc",
  surname: "Picard",
  password: "$stormpath2$SHA-512$1$ZFhBRmpFSnEwVEx2ekhKS0JTMDJBNTNmcg==$Q+sGFg9e+pe9QsUdfnbJUMDtrQNf27ezTnnGllBVkQpMRc9bqH6WkyE3y0svD/7cBk8uJW9Wb3dolWwDtDLFjg=="
}, password_format: 'mcf')

### Authentication

Authentication is accomplished by passing a username or an email and a
password to <code>authenticate_account</code> of an application we've
registered on Stormpath. This will either return a
<code>Stormpath::Authentication::AuthenticationResult</code> instance if
the credentials are valid, or raise a <code>Stormpath::Error</code>
otherwise. In the former case, you can get the <code>account</code>
associated with the credentials.

```ruby
auth_request =
  Stormpath::Authentication::UsernamePasswordRequest.new 'johnsmith', '4P@$$w0rd!'

begin
  auth_result = application.authenticate_account auth_request
  account = auth_result.account
rescue Stormpath::Error => e
  #If credentials are invalid or account doesn't exist
end
```

### Password Reset

A password reset workflow, if configured on the directory the account is
registered on, can be kicked off with the
<code>send_password_reset_email</code> method on an application:

```ruby
application.send_password_reset_email 'john.smith@example.com'
```

If the workflow has been configured to verify through a non-Stormpath
URL, you can verify the token sent in the query parameter
<code>sptoken</code> with the <code>verify_password_reset_token</code>
method on the application.

For example, suppose you have a Sinatra application that is verifying
the tokens. You use the following to carry it out:

```ruby
get '/users/verify' do
  token = params[:sptoken]
  account = application.verify_password_reset_token token
  #proceed to update session, display account, etc
end
```

With the account acquired you can then update the password:

```ruby
  account.password = new_password
  account.save
```

_NOTE :_ Confirming a new password is left up to the web application
code calling the Stormpath SDK. The SDK does not require confirmation.

### Social Providers

To access or create an account in an already created social Directory (facebook, google, github, linkedin),
it is required to gather Authorization Code on behalf of the user. This requires leveraging Oauth 2.0
protocol and the user's consent for your applications permissions. Once you have the access_token you can
access the account via get_provider_account method.

```ruby
provider = ‘facebook’ # can also be google, github, linkedin
request = Stormpath::Provider::AccountRequest.new(provider, :access_token, access_token)
application.get_provider_account(request)
```

### ACL through Groups

Memberships of accounts in certain groups can be used as an
authorization mechanism. As the <code>groups</code> collection property
on an account instance is <code>Enumerable</code>, you can use any of
that module's methods to determine if an account belongs to a specific
group:

```ruby
account.groups.any? {|group| group.name == 'administrators'}
```

You can create groups and assign them to accounts using the Stormpath
web console, or programmatically. Groups are created on directories:

```ruby
group = directory.groups.create name: 'administrators'
```

Group membership can be created by:

* Explicitly creating a group membership resource with your client:

  ```ruby
  group_membership = client.group_memberships.create group: group, account: account
  ```

* Using the <code>add_group</code> method on the account instance:

  ```ruby
  account.add_group group
  ```

* Using the <code>add_account</code> method on the group instance:

  ```ruby
  group.add_account account
  ```

You will need to reload the account or group resource after these
operations to ensure they've picked up the changes.
### Add Custom Data to Accounts or Groups

Account and Group resources have predefined fields that are useful to many applications, but you are likely to have your own custom data that you need to associate with an account or group as well.

For this reason, both the account and group resources support a linked custom_data resource that you can use for your own needs.

*Set Custom Data*
```ruby
account =  Stormpath::Resource::Account.new({ email: "test@example.com", given_name: 'Ruby SDK', password: 'P@$$w0rd', surname: 'SDK',})

account.custom_data["rank"] = "Captain"
account.custom_data["birth_date"] = "2305-07-13"
account.custom_data["birth_place"] = "La Barre, France"

 directory.create_account account
```

Notice how we did not call account.custom_data.save - creating the account (or updating it later via save) will automatically persist the account's customData resource. The account 'knows' that the custom data resource has been changed and it will propogate those changes automatically when you persist the account.

Groups work the same way - you can save a group and it's custom data resource will be saved as well.

*Delete a specific Custom Data field*
```ruby
account.custom_data["birth_date"] #=> "2305-07-13"
account.custom_data.delete("birth_date")
account.custom_data.save
```

*Delete all Custom Data*
```ruby
account.custom_data.delete
```

## Testing

### Setup

The functional tests of the SDK run against a Stormpath tenant. In that
account, create:

* An application reserved for testing.
* A directory reserved for test accounts. _Be sure to associate this
  directory to the test application as a login source_.
* Another directory reserved for test accounts with the account
  verification workflow turned on. _Be sure to associate this directory
  to the test application as a login source_.

The following environment variables need will then need to be set:

* <code>STORMPATH_SDK_TEST_API_KEY_ID</code> - The <code>id</code> from
  your Stormpath API key.
* <code>STORMPATH_SDK_TEST_API_KEY_SECRET</code> - The
  <code>secret</code> from your Stormpath API key.
* <code>STORMPATH_SDK_TEST_APPLICATION_URL</code> - The URL to the
  application created above.
* <code>STORMPATH_SDK_TEST_DIRECTORY_URL</code> - The URL to the first
  directory created above.
* <code>STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL</code> - The
  URL to the second directory created above.

### Running

Once properly configured, start the redis server with <code>redis-server</code> and the tests can be run as the default
<code>Rake</code> task:

```sh
$ rake
```

Or by specifying the <code>spec</code> task:

```sh
$ rake spec
```

Or through <code>rspec</code>

## Contributing

You can make your own contributions by forking the <code>development</code>
branch, making your changes, and issuing pull-requests on the
<code>development</code> branch.

### Building the Gem

To build and install the development branch yourself from the latest source:

```
$ git clone git@github.com:stormpath/stormpath-sdk-ruby.git
$ cd stormpath-sdk-ruby
$ rake gem
$ gem install pkg/stormpath-sdk-{version}.gem
```

## Quick Class Diagram

```
+-------------+
| Application |
|             |
+-------------+
       + 1
       |
       |           +-------------+
       |           | LoginSource |
       o- - - - - -|             |
       |           +-------------+
       |
       v 0..*
+--------------+            +--------------+
|  Directory   | 1        1 |   Account    |1
|              |<----------+|              |+----------+
|              |            |              |           |
|              | 1     0..* |              |0..*       |
|              |+---------->|              |+-----+    |
|              |            +--------------+      |    |         +-----------------+
|              |                                  |    |         | GroupMembership |
|              |                                  o- - o - - - - |                 |
|              |            +--------------+      |    |         +-----------------+
|              | 1     0..* |    Group     |1     |    |
|              |+---------->|              |<-----+    |
|              |            |              |           |
|              | 1        1 |              |0..*       |
|              |<----------+|              |<----------+
+--------------+            +--------------+
```

## Copyright & Licensing

Copyright &copy; 2013 Stormpath, Inc. and contributors.

This project is licensed under the [Apache 2.0 Open Source License](http://www.apache.org/licenses/LICENSE-2.0).

For additional information, please see the full [Project Documentation](https://www.stormpath.com/docs/ruby/product-guide).

  [bundler]: http://gembundler.com/
  [stormpath]: http://stormpath.com/
  [create-api-keys]: http://www.stormpath.com/docs/ruby/product-guide#AssignAPIkeys
  [stormpath_bootstrap]: https://github.com/stormpath/stormpath-sdk-ruby/wiki/Bootstrapping-Stormpath
  [rubygems-installation-docs]: http://docs.rubygems.org/read/chapter/3
  [stormpath-admin-login]: http://api.stormpath.com/login
  [create-api-keys]: http://www.stormpath.com/docs/ruby/product-guide#AssignAPIkeys
  [concepts]: http://www.stormpath.com/docs/stormpath-basics#keyConcepts
  [exchange-id-site-token]: https://docs.stormpath.com/rest/product-guide/latest/008_idsite.html#exchanging-the-id-site-jwt-for-an-oauth-token
  [generate-oauth-access-token]: https://docs.stormpath.com/rest/product-guide/latest/005_auth_n.html#generate-oauth-token
  [mcf-hash-password-doc]: http://docs.stormpath.com/rest/product-guide/latest/004_accnt_mgmt.html#importing-accounts-with-mcf-hash-passwords
  [stormpath-hash-algorithm]: http://docs.stormpath.com/rest/product-guide/latest/004_accnt_mgmt.html#the-stormpath2-hashing-algorithm
  [wildcard-certificate]: https://en.wikipedia.org/wiki/Wildcard_certificate
  [custom-domain-with-id-site]: https://docs.stormpath.com/guides/using-id-site/#setting-your-own-custom-domain-name-and-ssl-certificate
  [id-site-multitenancy]: https://docs.stormpath.com/guides/using-id-site/#using-id-site-for-multitenancy
