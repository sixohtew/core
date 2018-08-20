@api
Feature: delete groups
As an admin
I want to be able to delete groups
So that I can remove unnecessary groups

	Background:
		Given using OCS API version "1"

	@smokeTest
	Scenario: admin deletes a group
		Given group "simplegroup" has been created
		When the administrator deletes group "simplegroup" using the provisioning API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And group "simplegroup" should not exist

	Scenario Outline: admin deletes a group
		Given group "<group_id>" has been created
		When the administrator deletes group "<group_id>" using the provisioning API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And group "<group_id>" should not exist
		Examples:
			| group_id            | comment                                 |
			| new-group           | dash                                    |
			| the.group           | dot                                     |
			| left,right          | comma                                   |
			| España              | special European characters             |
			| नेपाली              | Unicode group name                      |
			| 0                   | The "false" group                       |
			| Finance (NP)        | Space and brackets                      |
			| Admin&Finance       | Ampersand                               |
			| admin:Pokhara@Nepal | Colon and @                             |
			| maintenance#123     | Hash sign                               |
			| maint+eng           | Plus sign                               |
			| $x<=>[y*z^2]!       | Maths symbols                           |
			| Mgmt\Middle         | Backslash                               |
			| 50%pass             | Percent sign (special escaping happens) |
			| 50%25=0             | %25 literal looks like an escaped "%"   |
			| 50%2Eagle           | %2E literal looks like an escaped "."   |
			| 50%2Fix             | %2F literal looks like an escaped slash |
			| staff?group         | Question mark                           |

	Scenario: normal user tries to delete the group
		Given user "brand-new-user" has been created
		And group "new-group" has been created
		And user "brand-new-user" has been added to group "new-group"
		When user "brand-new-user" sends HTTP method "DELETE" to OCS API endpoint "/cloud/groups/new-group"
		Then the OCS status code should be "997"
		And the HTTP status code should be "401"
		And group "new-group" should exist

	Scenario: subadmin of the group tries to delete the group
		Given user "subadmin" has been created
		And group "new-group" has been created
		And user "subadmin" has been made a subadmin of group "new-group"
		When user "subamin" sends HTTP method "DELETE" to OCS API endpoint "/cloud/groups/new-group"
		Then the OCS status code should be "997"
		And the HTTP status code should be "401"
		And group "new-group" should exist