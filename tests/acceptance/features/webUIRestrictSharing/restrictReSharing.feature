@webUI @insulated @disablePreviews
Feature: restrict resharing
As an admin
I want to be able to forbid the sharing of a received share globally
As a user
I want to be able to forbid a user that received a share from me to share it further

	Background:
		Given these users have been created:
		|username|password|displayname|email       |
		|user1   |1234    |User One   |u1@oc.com.np|
		|user2   |1234    |User Two   |u2@oc.com.np|
		|user3   |1234    |User Three |u2@oc.com.np|
		And these groups have been created:
		|groupname|
		|grp1     |
		And user "user1" has been added to group "grp1"
		And user "user2" has been added to group "grp1"
		And the user has browsed to the login page
		And the user has logged in with username "user2" and password "1234" using the webUI

	@skipOnMICROSOFTEDGE @TestAlsoOnExternalUserBackend
	@smokeTest
	Scenario: share a folder with another internal user and prohibit resharing
		Given the setting "Allow resharing" in the section "Sharing" has been enabled
		And the user has browsed to the files page
		When the user shares the folder "simple-folder" with the user "User One" using the webUI
		And the user sets the sharing permissions of "User One" for "simple-folder" using the webUI to
		| share | no |
		And the user re-logs in with username "user1" and password "1234" using the webUI
		Then it should not be possible to share the folder "simple-folder (2)" using the webUI

	@TestAlsoOnExternalUserBackend
	@smokeTest
	Scenario: forbid resharing globally
		Given the setting "Allow resharing" in the section "Sharing" has been disabled
		And the user has browsed to the files page
		When the user shares the folder "simple-folder" with the user "User One" using the webUI
		And the user re-logs in with username "user1" and password "1234" using the webUI
		Then it should not be possible to share the folder "simple-folder (2)" using the webUI
