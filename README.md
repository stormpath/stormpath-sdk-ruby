[![Build Status](https://api.travis-ci.org/stormpath/stormpath-sdk-ruby.png?branch=master)](https://travis-ci.org/stormpath/stormpath-sdk-ruby)
# Stormpath Ruby SDK

Stormpath is the first easy, secure user management and authentication service for developers.
This is the Ruby SDK to ease integration of its features with any Ruby language based
application.

## Setup

1. Install the <code>stormpath-sdk</code> gem, either via the command line:

    ```
    $ gem install stormpath-sdk
    ```

  or adding the gem to your [Bundler][bundler] Gemspec:

    ```
    gem 'stormpath-sdk'
    ```

  or any other preferred dependency.

2. Create a [Stormpath][stormpath] developer account and [create your API Keys][create-api-keys]
   downloading the <code>apiKey.properties</code> file into a <code>.stormpath</code>
   folder under your local home directory.

3. Create an application and a directory to store your users' accounts using the
  <code>stormpath_bootstrap</code> script, remembering to specify the application name:

    ```sh
    $ stormpath_bootstrap --application_name yourApplicationName
    ```

  This will generate a <code>stormpath.yml</code> file containing the URL paths
  to the newly created application and directory.

  Read more about <code>[stormpath_bootstrap][stormpath_bootstrap].

  You can alterantively create your application and directory manually.

## Contributing

You can make your own contributions by forking the <code>development</code>
branch, making your changes, and issuing pull-requests on the
<code>development</code> branch.

### Running Specs

You can run all the tests via Rake:

```sh
rake spec
```

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
