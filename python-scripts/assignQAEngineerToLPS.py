#!/usr/bin/env python

from jira import JIRA
import manageCredentialsCrypto

if __name__ == "__main__":
    print("Assigning QA Engineer to LPS tasks...")
    login = manageCredentialsCrypto.get_credentials()
    jira = JIRA("https://issues.liferay.com", basic_auth=login)
    stories_without_QA_engineer = jira.search_issues('filter=54607')
    for story in stories_without_QA_engineer:
        QAEngineer = [{'name': story.fields.assignee.name}]
        story.update(
            fields={'customfield_24852': QAEngineer}
        )

    print("LPS have QA Engineer field up to date")
