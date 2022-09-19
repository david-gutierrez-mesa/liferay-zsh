#!/usr/bin/env python

from jira import JIRA
import manageCredentialsCrypto

if __name__ == "__main__":
    print("Creating subtasks for Echo team")
    login = manageCredentialsCrypto.get_credentials()
    jira = JIRA("https://issues.liferay.com", basic_auth=login)
    stories_without_testing_subtask = jira.search_issues('filter=54572')
    for story in stories_without_testing_subtask:
        needs_backend = True
        needs_frontend = True
        for subtask in story.fields.subtasks:
            summary = subtask.fields.summary
            if summary == 'Test Scenarios Coverage | Backend':
                needs_backend = False
            elif summary == 'Test Scenarios Coverage | Frontend':
                needs_frontend = False

        components = []
        for component in story.fields.components:
            components.append({'name': component.name})

        if needs_backend:
            subtask_backend = {
                'project': {'key': 'LPS'},
                'summary': 'Test Scenarios Coverage | Backend',
                'description': '* Fill the Backend coverage on the test scenarios table, created in the parent story.\n'
                               '* Implement the Backend unit and/or integration tests that are missing, '
                               'comparing with the test scenarios table, created in the parent story.',
                'issuetype': {'name': 'Technical Testing'},
                'components': components,
                'parent': {'id': story.id},
            }
            child = jira.create_issue(fields=subtask_backend)
            print("Created sub-task: " + child.key + " for story " + story.id)

        if needs_frontend:
            subtask_frontend = {
                'project': {'key': 'LPS'},
                'summary': 'Test Scenarios Coverage | Frontend',
                'description': '* Fill the Frontend coverage on the test scenarios table, '
                               'created in the parent story.\n'
                               '* Implement the Backend unit and/or integration tests that are missing, '
                               'comparing with the test scenarios table, created in the parent story.',
                'issuetype': {'name': 'Technical Testing'},
                'components': components,
                'parent': {'id': story.id},
            }
            child = jira.create_issue(fields=subtask_frontend)
            print("Created sub-task: " + child.key + " for story " + story.id)

    print("Subtasks for Echo team are up to date")
