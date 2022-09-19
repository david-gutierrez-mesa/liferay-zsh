#!/usr/bin/env python

from jira import JIRA
import manageCredentialsCrypto

if __name__ == "__main__":
    login = manageCredentialsCrypto.get_credentials()
    jira = JIRA("https://issues.liferay.com", basic_auth=login)
    stories_without_testing_subtask = jira.search_issues('filter=54596')
    for story in stories_without_testing_subtask:
        test_creation = True
        test_validation = True
        automation_test_creation = True
        for subtask in story.fields.subtasks:
            summary = subtask.fields.summary
            if summary == 'Test Scenarios Coverage | Test Creation':
                test_creation = False
            elif summary == 'Product QA | Test Validation - Round 1':
                test_validation = False
            elif summary == 'Product QA | Automation Test Creation':
                automation_test_creation = False

        components = []
        for component in story.fields.components:
            components.append({'name': component.name})

        if test_creation:
            subtask_test_creation = {
                'project': {'key': 'LPS'},
                'summary': 'Test Scenarios Coverage | Test Creation',
                'description': 'Define the test scenarios of the parent epic. Instructions [here '
                               '|https://liferay.atlassian.net/l/c/Ed0yE1to].',
                'issuetype': {'name': 'Technical Testing'},
                'components': components,
                'parent': {'id': story.id},
            }
            child = jira.create_issue(fields=subtask_test_creation)
            print("Created sub-task: " + child.key)

        if test_validation:
            subtask_test_validation = {
                'project': {'key': 'LPS'},
                'summary': 'Product QA | Test Validation - Round 1',
                'description': 'Execute the tests of the parent epic. Instructions ['
                               'here|https://liferay.atlassian.net/l/c/VURAf9A3].',
                'issuetype': {'name': 'Technical Testing'},
                'components': components,
                'parent': {'id': story.id},
            }
            child = jira.create_issue(fields=subtask_test_validation)
            print("Created sub-task: " + child.key)

        if automation_test_creation:
            subtask_test_automation = {
                'project': {'key': 'LPS'},
                'summary': 'Product QA | Automation Test Creation',
                'description': 'Create test automation to validate the critical test scenarios/cases of the related '
                               'story. Instructions [here|https://liferay.atlassian.net/l/c/FUSUocqi].',
                'issuetype': {'name': 'Technical Testing'},
                'components': components,
                'parent': {'id': story.id},
            }
            child = jira.create_issue(fields=subtask_test_automation)
            print("Created sub-task: " + child.key)
