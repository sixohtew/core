@api
Feature: access user provisioning API using app password
As an ownCloud user
I want to be able to use the provisioning API with an app password
So that I can make a client app or script for provisioning users/groups that can use an app password instead of my real password.
	Background:
		Given using OCS API version "1"

	@smokeTest
	Scenario: admin deletes the user
		Given user "brand-new-user" has been created
		And group "new-group" has been created
		And a new client token for "admin" has been generated
		And a new browser session for "admin" has been started
		And the user has generated a new app password named "my-client"
		When the user requests "/ocs/v1.php/cloud/users/brand-new-user" with "DELETE" using the generated app password 
		Then the HTTP status code should be "200"
		And user "brand-new-user" should not exist

	Scenario: subadmin gets user of his group
		Given user "brand-new-user" has been created
		And user "another-new-user" has been created
		And group "new-group" has been created
		And user "another-new-user" has been added to group "new-group"
		And user "brand-new-user" has been made a subadmin of group "new-group"
		And a new client token for "brand-new-user" has been generated
		And a new browser session for "brand-new-user" has been started
		And the user has generated a new app password named "my-client"
		When the user requests "/ocs/v1.php/cloud/users" with "GET" using the generated app password 
		Then the users returned by the API should be
			| another-new-user |
		And the HTTP status code should be "200"

	@smokeTest
	Scenario: normal user gets his own information using the app password
		Given user "newuser" has been created
		And a new client token for "newuser" has been generated
		Given a new browser session for "newuser" has been started
		And the user has generated a new app password named "my-client"
		When the user requests "/ocs/v1.php/cloud/users/newuser" with "GET" using the generated app password
		Then the HTTP status code should be "200"
		And the display name returned by the API should be "newuser"

	Scenario: subadmin tries to get users of other group
		Given user "brand-new-user" has been created
		And user "another-new-user" has been created
		And group "new-group" has been created
		And group "another-new-group" has been created
		And user "another-new-user" has been added to group "another-new-group"
		And user "brand-new-user" has been made a subadmin of group "new-group"
		And a new client token for "brand-new-user" has been generated
		And a new browser session for "brand-new-user" has been started
		And the user has generated a new app password named "my-client"
		When the user requests "/ocs/v1.php/cloud/users" with "GET" using the generated app password 
		Then the users returned by the API should not include "another-new-user"
		And the HTTP status code should be "200"

	Scenario: normal user tries to get other user information using the app password
		Given user "newuser" has been created
		And user "anotheruser" has been created
		And a new client token for "newuser" has been generated
		Given a new browser session for "newuser" has been started
		And the user has generated a new app password named "my-client"
		When the user requests "/ocs/v1.php/cloud/users/anotheruser" with "GET" using the generated app password
		Then the OCS status code should be "997"
		And the HTTP status code should be "401"
		And the API should not return any data
