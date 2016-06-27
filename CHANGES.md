stormpath-sdk-ruby Changelog
============================

Version 1.1.3
-------------

Released on June 27, 2016

- Add Password Policy, PasswordStrength, ResetEmailTemplates and ResetSuccessEmailTemplates
- Add Account Creation Policy
- Add Oauth Verification with Stormpath Tokens
- Add Account Api Keys

Version 1.1.2
-------------

Released on May 24, 2016

- Add AccessToken and RefreshToken resources

Version 1.1.1
-------------

Released on May 19, 2016

- Add timestamps (created_at & modified_at) for account, application, custom_data,
  directory, group, organization and tenant resource

Version 1.1.0
-------------

Released on May 11, 2016

- Saml integration
- Support for specifying an organization name_key on login attempts
- Support for specifying the account store when reseting passwords
- Add delegate to organizations
- Add Organization docs to README

Version 1.0.1
-------------

Released on February 16, 2016

-- Added missing organizations collection to the tenant resource.


Version 1.0.0.beta.9
--------------------

Released on December 2, 2015

- Organization CRUD
- Token Management
- Ability to specify an organization nameKey as an accountStore for loginAttempt
- Get applications for an account
- Resending email verification

Version 1.0.0.beta.8
--------------------

Released on July 28, 2015

- Added support for Id Site.
- Added custom data support for tenant, application and directory resources.
- Added the size property to the collection resources.


Version 1.0.0.beta.7
--------------------

Released on July 21, 2014

- Added provider integration (Google, Facebook and Stormpath).
- Updated tests to use RSpec3.
- Updated tests to run in parallel in multiple versions (1.9.3, 2.0.0 and 2.1.2).


Version 1.0.0.beta.6
--------------------

Released on July 7, 2014

- Fixed custom data deletion issue.
- Added resource pagination functionality.
- Fixed issue when searching by email.


Version 1.0.0.beta.5
--------------------

Released on March 3, 2014

- Added the Custom Data resource
- Added CustomDataStorage module
- Specify an AccountStore during authentication
- Added AccountStatus module (specialization of the Status module)
- Added Status spec
- Added AccountMemberships
- Added GroupMemberships spec
- Send only dirty properties to the API
- Fixed REDIRECTS_LIMIT issue

Version 1.0.0.beta.4
--------------------

Released on December 10, 2013

- Added the Account Store CRUD (AccountStore and AccountStoreMapping resources)
- Added the full_name prop_reader to the Account resource

Version 1.0.0.beta.3
--------------------

Released on September 25, 2013

- Added support for using special characters in account resource fields (e.g., username, password, etc.) when creating or updating a resource
- Added "createDirectory=true" option to the application.create method to allow automatic creation of a directory when creating an application. Refer to readme for more info.

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
