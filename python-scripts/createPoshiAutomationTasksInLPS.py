#!/usr/bin/env python

from jira import JIRA
import manageCredentialsCrypto


def create_poshi_task_for(jira, parent_story, poshi_automation_table):
    parent_key = parent_story.key
    print("Creating automation task for ", parent_key)
    epic_link = parent_story.get_field('customfield_12821')
    components = []
    for component in story.fields.components:
        components.append({'name': component.name})
    issue_dict = {
        'project': {'key': 'LPS'},
        'summary': parent_key + ' - Product QA | Test Automation Creation',
        'description': 'Create test automation to validate the critical test scenarios/cases of the related '
                       'story.\n\nThe focus of this task is to implement the CRITICAL, HIGH, and MID tests of the '
                       'related story, but if you believe that can and have time to implement the LOW and TRIVIAL '
                       'test cases, please, create one more subtask to it, and go ahead!\n\nh3. Test Scenarios\n'
                       + poshi_automation_table,
        'issuetype': {'name': 'Testing'},
        'components': components,
        'customfield_12821': epic_link
    }

    new_issue = jira.create_issue(fields=issue_dict)
    jira.create_issue_link(
        type="relates",
        inwardIssue=new_issue.key,
        outwardIssue=parent_key,
    )
    print("Poshi task ", new_issue.key, " created for", parent_key)


if __name__ == "__main__":
    print("Creating Poshi tasks...")
    outputMessage = ''

    login = manageCredentialsCrypto.get_credentials()
    jira = JIRA("https://issues.liferay.com", basic_auth=login)
    stories_without_Poshi_automation_created = jira.search_issues('filter=54646')
    for story in stories_without_Poshi_automation_created:
        isAutomationTaskNeeded = False
        description = story.fields.description
        tableStarringString = '||Test Scenarios||'
        tableStaringPosition = description.find(tableStarringString)
        if tableStaringPosition != -1:
            skipStory = False
            table = description[tableStaringPosition:]
            tableRows = table.split('\r\n')
            poshiAutomationTable = tableRows[0] + 'testcase||Test Name||' + '\r\n'
            for row in tableRows[1:]:
                if row.count('|') == 7:
                    cells = row.split('|')
                    if cells[2].casefold() == 'TBD'.casefold() \
                            or cells[4].casefold() == 'TBD'.casefold() \
                            or cells[5].casefold() == 'TBD'.casefold():
                        outputMessage += "Table for story " + story.key + " is not uptodate. Skipping.\n"
                        skipStory = True
                        break
                    elif (cells[4].casefold() == 'No'.casefold() and cells[5].casefold() == 'No'.casefold()) \
                            and cells[6].casefold() == 'Yes'.casefold():
                        isAutomationTaskNeeded = True
                    poshiAutomationTable += row + ' | |' + '\r\n'
                else:
                    break
            if skipStory:
                break
            if isAutomationTaskNeeded:
                hashPoshiSubtask = [subtask for subtask in story.get_field('subtasks') if subtask.fields.summary ==
                                    'Product QA | Functional Automation']
                if hashPoshiSubtask:
                    outputMessage += "Story " + story.key + " has already a POSHI subtask.\n"
                else:
                    create_poshi_task_for(jira, story, poshiAutomationTable)
            else:
                print("Automation task not needed or not possible to create")
        else:
            outputMessage += "Story " + story.key + " don't have test table. \n"

    print(outputMessage)
