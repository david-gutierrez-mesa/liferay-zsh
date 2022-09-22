#!/usr/bin/env python

from jira import JIRA
import manageCredentialsCrypto

if __name__ == "__main__":
    print("Closing bugs in Ready for Release status...")
    login = manageCredentialsCrypto.get_credentials()
    jira = JIRA("https://issues.liferay.com", basic_auth=login)
    bugs_in_ready_for_release = jira.search_issues('filter=54632')
    for bug in bugs_in_ready_for_release:
        bug_id = bug.id
        print("Closing ", bug_id)
        if not bug.fields.fixVersions:
            fixVersion = [{'name': 'Master'}]
            bug.update(
                fields={'fixVersions': fixVersion}
            )
        jira.transition_issue(bug_id, transition='Closed')
        jira.add_comment(bug_id, 'Closing directly since we are not considering Ready for Release status so far',
                         visibility={'type': 'group', 'value': 'liferay-qa'})

    print("Ready for Release status are closed")
