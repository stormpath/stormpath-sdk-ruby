[![Build Status](https://api.travis-ci.org/stormpath/stormpath-sdk-ruby.png?branch=master)](https://travis-ci.org/stormpath/stormpath-sdk-ruby)

# Stormpath Ruby SDK

Stormpath is the first easy, secure user management and authentication service for developers.
This is the Ruby SDK to ease integration of its features with any Ruby language based
application.

## Install

```sh
$ gem install stormpath-sdk
```

## Quickstart Guide

1.  If you have not already done so, register as a developer on
    [Stormpath][stormpath] and set up your API credentials and resources:

    1.  Create a [Stormpath][stormpath] developer account and [create your API Keys][create-api-keys]
        downloading the <code>apiKey.properties</code> file into a <code>.stormpath</code>
        folder under your local home directory.

    1.  Create an application and a directory to store your users'
        accounts. Make sure the directory is assigned as a login source
        to the application.

    1.  Take note of the _REST URL_ of the application and of directory
        you just created.

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
    account = clients.accounts.get account.href
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
  group_memebership = client.group_memberships.create group, account
  ```

* Using the <code>add_group</code> method on the account instance:

  ```ruby
  account.add_group group
  ```

* Using the <code>add_account</code> method on the group instance:

  ```ruby
  group.add_group account
  ```

You will need to reload the account or group resource after these
operations to ensure they've picked up the changes.

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

Once properly configured, the tests can be run as the default
<code>Rake<code> task:

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
