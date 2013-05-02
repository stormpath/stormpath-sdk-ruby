[![Build Status](https://api.travis-ci.org/stormpath/stormpath-sdk-ruby.png?branch=master)](https://travis-ci.org/stormpath/stormpath-sdk-ruby)

# Stormpath Ruby SDK

Stormpath is the first easy, secure user management and authentication service for developers.
This is the Ruby SDK to ease integration of its features with any Ruby language based
application.

## Install

1.  Install the gem:

    ```sh
    $ gem install stormpath-sdk
    ```

## Quickstart Guide

1.  If you have not already done so, register as a developer on
    [Stormpath][stormpath] and set up your API credentials and resources:

    1.  Create a [Stormpath][stormpath] developer account and [create your API Keys][create-api-keys]
        downloading the <code>apiKey.properties</code> file into a <code>.stormpath</code>
        folder under your local home directory.
        
    1.  Create an application an a directory to store your users'
        accounts.

    1.  Take note of the _REST URL_ of the application and of directory
        you just created.

1.  **Require the Stormpath Ruby SDK**

    ```ruby
    require 'stormpath-sdk'
    ```

1.  **Create a client** using the API key file or through other ways

    ```ruby
    client = Stormpath::Client.new api_key_file_location: File.join(ENV['HOME']), '.stormpath', 'apiKey.properties')
    ```

1.  **List all your applications and directories**

    ```ruby
    client.applications.each do |application|
      p "Application: #{application.name}"
    end

    client.directories.each do |directory|
      p 'Directory: #{directory.name}"
    end
    ```

1.  **Get access to the specific application and directory** using the
    URLs you acquired above.

    ```ruby
    application = client.applications.get application_url

    directory = client.directories.get application_url
    ```

1.  **Create an account for a user** on the directory.

    ```ruby
    account = directory.accounts.create({
      given_name: 'John',
      surname: 'Smith',
      email: 'john.smith@example.com',
      username = 'johnsmith'
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

## General Usage

### Creating a client:

With an API key properties file:

With an APIKey instance:

By explicitly setting the API key id and secret:

With credentials embedded in an application URL:

### Working trough an Application and Directory

### Registering Accounts

### Authentication

### Password Reset

### ACL through Groups

## Resource Management

### Applications

Listing applications:

Getting an application:

Creating an application:

Updating an application:

Deleting an application:

Authenticating an account:

### Directories

Listing directories:

Getting a directory:

Creating a directory:

Updating a directory:

Deleting a directory

### Accounts

Listing Accounts:

Getting an account:

Creating an account:

Updating an account:

Deleting an account:

### Groups

Listing groups:

Get a group:

Create a group:

Update a group:

### Group Memberships

Listing group memberships:

Creating a group membership:

Get a group membership:

Delete a group membership:

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

## Running

Once properly configured, the tests can be run as the default
<code>Rake<code> task:

```sh
$ rake
```

Or by specifying the <code>spec</code> task:

```sh
$ rake spec
```

Or through <code>rspec</code>.

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

## Copyright & Licensing

Copyright &copy; 2012 Stormpath, Inc. and contributors.

This project is licensed under the [Apache 2.0 Open Source License](http://www.apache.org/licenses/LICENSE-2.0).

For additional information, please see the full [Project Documentation](https://www.stormpath.com/docs/ruby/product-guide).

  [bundler]: http://gembundler.com/
  [stormpath]: http://stormpath.com/
  [create-api-keys]: http://www.stormpath.com/docs/ruby/product-guide#AssignAPIkeys
  [stormpath_bootstrap]: https://github.com/stormpath/stormpath-sdk-ruby/wiki/Bootstrapping-Stormpath
