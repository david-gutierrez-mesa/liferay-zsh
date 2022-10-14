#!/usr/bin/env python

from jira import JIRA
import manageCredentialsCrypto


def get_property(local_case, property_name):
    test_property = 'TBD'
    string_start = local_case.find(property_name) + len(property_name)
    if string_start != -1:
        string_end = local_case.find('\r\n', string_start)
        test_property = local_case[string_start:string_end].strip()
    return test_property


if __name__ == "__main__":
    print("Creating tests table for Echo team...")
    login = manageCredentialsCrypto.get_credentials()
    jira = JIRA("https://issues.liferay.com", basic_auth=login)
    stories_without_testing_table = jira.search_issues('filter=54772')
    for story in stories_without_testing_table:
        current_description = story.fields.description
        poshiAutomationTable = '||Test Scenarios||Test Strategy||Kind of test||Is it covered by FrontEnd ? (' \
                               'JS-Unit)||Is it covered by BackEnd ? (unit or integration)||Could it be covered by ' \
                               'POSHI?||' + '\r\n'
        for subtask in story.fields.subtasks:
            summary = subtask.fields.summary
            if summary == 'Test Scenarios Coverage | Test Creation':
                test_definitions = jira.issue(subtask.id, fields='description').fields.description.split('\r\n*Case')
                for case in test_definitions[1:]:
                    case_summary = get_property(case, ':*\r\n')
                    case_priority = get_property(case, 'Test Strategy:')
                    can_be_automated = get_property(case, 'Can be covered by POSHI?:')

                    poshiAutomationTable += '|' + case_summary + '|' + case_priority + '|Manual|TBD|TBD|' \
                                            + can_be_automated + '|' + '\r\n'
                break

        updated_description = current_description + '\r\n\r\nh3. Test Scenarios\r\n' + poshiAutomationTable
        print("Crating table for story " + story.key)
        story.update(fields={'description': updated_description})

    print("All stories have testing table")
