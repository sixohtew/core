@api @TestAlsoOnExternalUserBackend
Feature: accept/decline shares coming from internal users
	As a user
	I want to have control of which received shares I accept
	So that I can keep my file system clean

	Background:
		Given using OCS API version "1"
		And using new DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And group "grp1" has been created
		And user "user1" has been added to group "grp1"
		And user "user2" has been added to group "grp1"

	Scenario: share a file & folder with another internal user when auto accept is enabled
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		When user "user0" shares folder "/PARENT" with user "user1" using the sharing API
		And user "user0" shares file "/textfile0.txt" with user "user1" using the sharing API
		Then user "user1" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0.txt           |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /PARENT (2)/             |
			| /textfile0 (2).txt       |

	Scenario: share a file & folder with internal group when auto accept is enabled
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		When user "user0" shares folder "/PARENT" with group "grp1" using the sharing API
		And user "user0" shares file "/textfile0.txt" with group "grp1" using the sharing API
		Then user "user1" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0.txt           |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /PARENT (2)/             |
			| /textfile0 (2).txt       |
		And user "user2" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0.txt           |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user2" that these shares are in the accepted state
			| path                     |
			| /PARENT (2)/             |
			| /textfile0 (2).txt       |

	Scenario: decline a share that has been auto-accepted
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user0" has shared file "/textfile0.txt" with user "user1"
		When user "user1" declines the share "/PARENT (2)" offered by user "user0" using the sharing API
		And user "user1" declines the share "/textfile0 (2).txt" offered by user "user0" using the sharing API
		Then user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the declined state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |

	Scenario: accept a share that has been declined before
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user0" has shared file "/textfile0.txt" with user "user1"
		And user "user1" has declined the share "/PARENT (2)" offered by user "user0"
		And user "user1" has declined the share "/textfile0 (2).txt" offered by user "user0"
		When user "user1" accepts the share "/PARENT" offered by user "user0" using the sharing API
		And user "user1" accepts the share "/textfile0.txt" offered by user "user0" using the sharing API
		Then user "user1" should see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /PARENT (2)/             |
			| /textfile0 (2).txt       |

	Scenario: unshare a share that has been auto-accepted
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user0" has shared file "/textfile0.txt" with user "user1"
		When user "user1" unshares folder "/PARENT (2)" using the WebDAV API
		And user "user1" unshares file "/textfile0 (2).txt" using the WebDAV API
		Then user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the declined state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |

	Scenario: unshare a share that was shared with a group and auto-accepted
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has shared folder "/PARENT" with group "grp1"
		And user "user0" has shared file "/textfile0.txt" with group "grp1"
		When user "user1" unshares folder "/PARENT (2)" using the WebDAV API
		And user "user1" unshares file "/textfile0 (2).txt" using the WebDAV API
		Then user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the declined state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |
		But user "user2" should see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user2" that these shares are in the accepted state
			| path                     |
			| /PARENT (2)/             |
			| /textfile0 (2).txt       |

	Scenario: rename accepted share, decline it
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has shared folder "/PARENT" with user "user1"
		When user "user1" moves folder "/PARENT (2)" to "/PARENT-renamed" using the WebDAV API
		And user "user1" declines the share "/PARENT-renamed" offered by user "user0" using the sharing API
		Then user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT-renamed/         |
		And the sharing API should report to user "user1" that these shares are in the declined state
			| path                     |
			| /PARENT/                 |

	Scenario: rename accepted share, decline it then accept again, name stays
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user1" has moved folder "/PARENT (2)" to "/PARENT-renamed"
		When user "user1" declines the share "/PARENT-renamed" offered by user "user0" using the sharing API
		And user "user1" accepts the share "/PARENT" offered by user "user0" using the sharing API
		Then user "user1" should see the following elements
			| /PARENT/                 |
			| /PARENT-renamed/         |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /PARENT-renamed/         |

	Scenario: move accepted share, decline it, accept again
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has created a folder "/shared"
		And user "user0" has shared folder "/shared" with user "user1"
		And user "user1" has moved folder "/shared" to "/PARENT/shared"
		When user "user1" declines the share "/PARENT/shared" offered by user "user0" using the sharing API
		And user "user1" accepts the share "/shared" offered by user "user0" using the sharing API
		Then user "user1" should not see the following elements
			| /shared/                 |
		But user "user1" should see the following elements
			| /PARENT/shared/          |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /PARENT/shared/          |

	Scenario: move accepted share, decline it, delete parent folder, accept again
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has created a folder "/shared"
		And user "user0" has shared folder "/shared" with user "user1"
		And user "user1" has moved folder "/shared" to "/PARENT/shared"
		When user "user1" declines the share "/PARENT/shared" offered by user "user0" using the sharing API
		And user "user1" deletes folder "/PARENT" using the WebDAV API
		And user "user1" accepts the share "/shared" offered by user "user0" using the sharing API
		Then user "user1" should not see the following elements
			| /PARENT/                 |
		But user "user1" should see the following elements
			| /shared/                 |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /shared/                 |

	Scenario: receive two shares with identical names from different users
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "yes"
		And user "user0" has created a folder "/shared"
		And user "user0" has created a folder "/shared/user0"
		And user "user1" has created a folder "/shared"
		And user "user1" has created a folder "/shared/user1"
		When user "user0" shares folder "/shared" with user "user2" using the sharing API
		And user "user1" shares folder "/shared" with user "user2" using the sharing API
		Then user "user2" should see the following elements
			| /shared/user0/           |
			| /shared%20(2)/user1/     |
		And the sharing API should report to user "user2" that these shares are in the accepted state
			| path                     |
			| /shared/                 |
			| /shared (2)/             |

	Scenario: share a file & folder with another internal group when auto accept is disabled
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		When user "user0" shares folder "/PARENT" with group "grp1" using the sharing API
		And user "user0" shares file "/textfile0.txt" with group "grp1" using the sharing API
		Then user "user1" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /textfile0.txt           |
		But user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the pending state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |
		And user "user2" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /textfile0.txt           |
		But user "user2" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user2" that these shares are in the pending state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |

	Scenario: share a file & folder with another internal user when auto accept is disabled
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		When user "user0" shares folder "/PARENT" with user "user1" using the sharing API
		And user "user0" shares file "/textfile0.txt" with user "user1" using the sharing API
		Then user "user1" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /textfile0.txt           |
		But user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the pending state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |

	Scenario: accept a pending share
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user0" has shared file "/textfile0.txt" with user "user1"
		When user "user1" accepts the share "/PARENT" offered by user "user0" using the sharing API
		And user "user1" accepts the share "/textfile0.txt" offered by user "user0" using the sharing API
		Then user "user1" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /textfile0.txt           |
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /PARENT (2)/             |
			| /textfile0 (2).txt       |

	Scenario: accept an accepted share
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		And user "user0" has created a folder "/shared"
		And user "user0" has shared folder "/shared" with user "user1"
		When user "user1" accepts the share "/shared" offered by user "user0" using the sharing API
		And user "user1" accepts the share "/shared" offered by user "user0" using the sharing API
		Then user "user1" should see the following elements
			| /shared/    |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path        |
			| /shared/    |

	Scenario: declines a pending share
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user0" has shared file "/textfile0.txt" with user "user1"
		When user "user1" declines the share "/PARENT" offered by user "user0" using the sharing API
		And user "user1" declines the share "/textfile0.txt" offered by user "user0" using the sharing API
		Then user "user1" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /textfile0.txt           |
		But user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the declined state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |

	Scenario: decline an accepted share
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user0" has shared file "/textfile0.txt" with user "user1"
		And user "user1" has accepted the share "/PARENT" offered by user "user0"
		And user "user1" has accepted the share "/textfile0.txt" offered by user "user0"
		When user "user1" declines the share "/PARENT (2)" offered by user "user0" using the sharing API
		And user "user1" declines the share "/textfile0 (2).txt" offered by user "user0" using the sharing API
		Then user "user1" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the declined state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |
			
	Scenario: deleting shares in pending state
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		And user "user0" has shared folder "/PARENT" with user "user1"
		And user "user0" has shared file "/textfile0.txt" with user "user1"
		When user "user0" deletes folder "/PARENT" using the WebDAV API
		And user "user0" deletes file "/textfile0.txt" using the WebDAV API
		Then the sharing API should report that no shares are shared with user "user1"

	Scenario: only one user in a group accepts a share
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		And user "user0" has shared folder "/PARENT" with group "grp1"
		And user "user0" has shared file "/textfile0.txt" with group "grp1"
		When user "user1" accepts the share "/PARENT" offered by user "user0" using the sharing API
		And user "user1" accepts the share "/textfile0.txt" offered by user "user0" using the sharing API
		Then user "user2" should not see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user2" that these shares are in the pending state
			| path                     |
			| /PARENT/                 |
			| /textfile0.txt           |
		But user "user1" should see the following elements
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /textfile0%20(2).txt     |
		And the sharing API should report to user "user1" that these shares are in the accepted state
			| path                     |
			| /PARENT (2)/             |
			| /textfile0 (2).txt       |

	Scenario: receive two shares with identical names from different users, accept one by one
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		And user "user0" has created a folder "/shared"
		And user "user0" has created a folder "/shared/user0"
		And user "user1" has created a folder "/shared"
		And user "user1" has created a folder "/shared/user1"
		And user "user0" has shared folder "/shared" with user "user2"
		And user "user1" has shared folder "/shared" with user "user2"
		When user "user2" accepts the share "/shared" offered by user "user1" using the sharing API
		And user "user2" accepts the share "/shared" offered by user "user0" using the sharing API
		Then user "user2" should see the following elements
			| /shared/user1/           |
			| /shared%20(2)/user0/     |
		And the sharing API should report to user "user2" that these shares are in the accepted state
			| path                     |
			| /shared/                 |
			| /shared (2)/             |

	Scenario: share with a group that you are part of yourself
		Given parameter "shareapi_auto_accept_share" of app "core" has been set to "no"
		When user "user0" shares folder "/PARENT" with group "grp1" using the sharing API
		Then the sharing API should report to user "user1" that these shares are in the pending state
			| path                     |
			| /PARENT/                 |
		And the sharing API should report that no shares are shared with user "user0"
