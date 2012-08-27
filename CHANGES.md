stormpath-sdk-ruby Changelog
====================

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