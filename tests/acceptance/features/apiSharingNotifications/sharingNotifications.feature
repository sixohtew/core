@api @app-required @notifications-app-required @TestAlsoOnExternalUserBackend
Feature: Display notifications when receiving a share
	As a user
	I want to see notifications about shares that have been offered to me
	So that I can easily decide what I want to do with new received shares

	Background:
		Given the app "notifications" has been enabled
		And using OCS API version "1"
		And using new DAV path
		And these users have been created: 
			|username|displayname|
			|user0   |User Zero  |
			|user1   |User One   |
			|user2   |User Two   |
		And these groups have been created:
			|groupname|
			|grp1     |
		And user "user1" has been added to group "grp1"
		And user "user2" has been added to group "grp1"

	@smokeTest
	Scenario: share to user sends notification
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		When user "user0" shares folder "/PARENT" with user "user1" using the sharing API
		And user "user0" shares file "/textfile0.txt" with user "user1" using the sharing API
		Then user "user1" should have 2 notifications
		And the last notification of user "user1" should match these regular expressions
			| app         | /^files_sharing$/                            |
			| subject     | /^"User Zero" shared "PARENT" with you$/     |
			| message     | /^"User Zero" invited you to view "PARENT"$/ |
			| link        | /^%base_url%(\/index\.php)?\/f\/(\d+)$/      |
			| object_type | /^local_share$/                              |

	Scenario: share to group sends notification to every member
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		When user "user0" shares folder "/PARENT" with group "grp1" using the sharing API
		And user "user0" shares file "/textfile0.txt" with group "grp1" using the sharing API
		Then user "user1" should have 2 notifications
		And the last notification of user "user1" should match these regular expressions
			| app         | /^files_sharing$/                            |
			| subject     | /^"User Zero" shared "PARENT" with you$/     |
			| message     | /^"User Zero" invited you to view "PARENT"$/ |
			| link        | /^%base_url%(\/index\.php)?\/f\/(\d+)$/      |
			| object_type | /^local_share$/                              |
		And user "user2" should have 2 notifications
		And the last notification of user "user2" should match these regular expressions
			| app         | /^files_sharing$/                            |
			| subject     | /^"User Zero" shared "PARENT" with you$/     |
			| message     | /^"User Zero" invited you to view "PARENT"$/ |
			| link        | /^%base_url%(\/index\.php)?\/f\/(\d+)$/      |
			| object_type | /^local_share$/                              |

	Scenario: when auto-accepting is enabled no notifications are sent
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		When user "user0" shares folder "/PARENT" with user "user1" using the sharing API
		And user "user0" shares file "/textfile0.txt" with user "user1" using the sharing API
		Then user "user1" should have 0 notifications

	@skipOnLDAP
	Scenario: discard notification if target user is not member of the group anymore
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		When user "user0" shares folder "/PARENT" with group "grp1" using the sharing API
		And the administrator removes user "user1" from group "grp1" using the provisioning API
		Then user "user1" should have 0 notifications
		Then user "user2" should have 1 notification

	@skipOnLDAP
	Scenario: discard notification if group is deleted
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		When user "user0" shares folder "/PARENT" with group "grp1" using the sharing API
		And the administrator deletes group "grp1" using the provisioning API
		Then user "user1" should have 0 notifications
		Then user "user2" should have 0 notifications
