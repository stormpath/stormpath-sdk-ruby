stormpath-sdk-ruby Changelog
============================

Version 1.0.0.beta.2
--------------------

Released on June 25, 2013

- Fixed current tenant redirection handling.
- Added expansion functionality to tenant retrieval from client.
- Added tenant retrieval by HREF functionality.
- Fixed tenant collection retrieval implementation in 'associations.rb'.

Version 1.0.0.beta
------------------

Released on June 12, 2013

- Bumping version to reflect stability

Version 1.0.0.alpha
-------------------

Released on June 11, 2013

- Added a new API on client for accessing applications and directories
- Added a new API on directories for accessing and creating accounts and groups
- Added account authentication by application
- Added the ability to load an application by credentialed uri
- Added caching, with Redis default
- Added pagination and querying to collections
- Added entity expansion

Version 0.4.0
-------------

Released on October 26, 2012

- The Stormpath::Resource::GroupMembership class now extends the Stormpath::Resource::Resource class. It is no longer possible to call 'save' on an instance of this class.
- The 'create' method of the Stormpath::Resource::GroupMembership class is now a class method and receives an instance of Stormpath::DataStore::DataStore; it was renamed from 'create' to '_create'.
- The 'add_group' method implementation of the Stormpath::Resource::Account class was updated to reflect the previously mentioned changes.
- The 'add_account' method implementation of the Stormpath::Resource::Group class was updated to reflect the previously mentioned changes.
- The 'set_account' and 'set_group' methods were removed from the Stormpath::Resource::GroupMembership class.
- The 'get_account' method implementation of Stormpath::Authentication::AuthenticationResult changed to use the Account's fully qualified name.
- The 'build' method implementation of Stormpath::Client::ClientApplicationBuilder changed to use the Application's fully qualified name.
- The 'save', 'delete' and 'save_resource' methods implementations of Stormpath::DataStore::DataStore were changed to receive the Resource's fully qualified name in the 'assert_kind_of' method calls.
- The 'authenticate' method implementation of Stormpath::Authentication::BasicAuthenticator was changed to replace 'password' variable's Array to String conversion from 'to_s' to 'join'.
- The 'to_class_from_instance' method implementation was completely changed to use activesupport's 'constantize' method, and to enable caching of the already "constantized" values.


Version 0.3.0
-------------

Released on August 31, 2012

- The properties method is now protected, only available for the resources hierarchy. The properties on the data store are now obtained via Stormpath::Resource::Resource's get_property_names and get_property functions.
- The 'inspect' and 'to_s' methods were overridden in Stormpath::Resource::Resource to keep some properties (like password) from being displayed.
- Logic to retain non-persisted properties was added (dirty properties).
- A resource's property can now be removed by setting it to nil.
- The Stormpath::Client::ClientApplicationBuilder class was added and implemented to produce a Stormpath::Client::ClientApplication from a single URL with the credentials on it.


Version 0.2.0
-------------

Released on August 20, 2012

- Result of the Application authentication was changed from Account to AuthenticationResult.
- The password verification's method name for token creation on the Application class was changed to 'send_password_reset_email'.
- The 'verify_password_reset_token' method on the Application class now returns an Account instead of a PasswordResetToken.
- The API RDOC was updated for the previously modified implementations on the Application class.

Version 0.1.0
-------------

Released on July 27, 2012

- First release of the Stormpath Ruby SDK where all of the features available on the REST API by the release date were implemented.
