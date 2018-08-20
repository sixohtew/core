@api @TestAlsoOnExternalUserBackend
Feature: sharing
	Background:
		Given using OCS API version "1"
		And using old DAV path
		And user "user0" has been created
		And user "user1" has been created

	@smokeTest
	Scenario: moving a file into a share as recipient
		Given user "user0" has created a folder "/shared"
		And user "user0" has shared folder "/shared" with user "user1"
		When user "user1" moves file "/textfile0.txt" to "/shared/shared_file.txt" using the WebDAV API
		Then as "user1" the file "/shared/shared_file.txt" should exist
		And as "user0" the file "/shared/shared_file.txt" should exist

	@smokeTest
	Scenario: moving a file out of a share as recipient creates a backup for the owner
		Given user "user0" has created a folder "/shared"
		And user "user0" has moved file "/textfile0.txt" to "/shared/shared_file.txt"
		And user "user0" has shared file "/shared" with user "user1"
		And user "user1" has moved folder "/shared" to "/shared_renamed"
		When user "user1" moves file "/shared_renamed/shared_file.txt" to "/taken_out.txt" using the WebDAV API
		Then as "user1" the file "/taken_out.txt" should exist
		And as "user0" the file "/shared/shared_file.txt" should not exist
		And as "user0" the file "/shared_file.txt" should exist in trash

	Scenario: moving a folder out of a share as recipient creates a backup for the owner
		Given user "user0" has created a folder "/shared"
		And user "user0" has created a folder "/shared/sub"
		And user "user0" has moved file "/textfile0.txt" to "/shared/sub/shared_file.txt"
		And user "user0" has shared file "/shared" with user "user1"
		And user "user1" has moved folder "/shared" to "/shared_renamed"
		When user "user1" moves folder "/shared_renamed/sub" to "/taken_out" using the WebDAV API
		Then as "user1" the file "/taken_out" should exist
		And as "user0" the folder "/shared/sub" should not exist
		And as "user0" the folder "/sub" should exist in trash
		And as "user0" the file "/sub/shared_file.txt" should exist in trash