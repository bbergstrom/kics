package Cx

import data.generic.ansible as ans_lib
import data.generic.common as common_lib

modules := {"community.aws.iam_managed_policy", "iam_managed_policy"}

CxPolicy[result] {
	task := ans_lib.tasks[id][t]
	awsApiGateway := task[modules[m]]
	ans_lib.checkState(awsApiGateway)

	st := common_lib.get_statement(common_lib.get_policy(awsApiGateway.policy))
	statement := st[_]

	common_lib.is_allow_effect(statement)
	not common_lib.equalsOrInArray(statement.Resource, lower("arn:aws:iam::aws:policy/AdministratorAccess"))
	common_lib.equalsOrInArray(statement.Action, "*")

	result := {
		"documentId": id,
		"resourceType": modules[m],
		"resourceName": task.name,
		"searchKey": sprintf("name={{%s}}.{{%s}}.policy", [task.name, modules[m]]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": "'iam_managed_policy.policy.Statement.Resource' should not have full permissions without being Admin",
		"keyActualValue": "'iam_managed_policy.policy.Statement.Resource' has full permissions and is not Admin",
		"searchLine": common_lib.build_search_line(["playbooks", t, modules[m], "policy"], []),
	}
}
