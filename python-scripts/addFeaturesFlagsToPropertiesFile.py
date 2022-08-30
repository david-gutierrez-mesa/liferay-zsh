#!/usr/bin/env python
import os

from jira import JIRA
from pathlib import Path
import manageCredentialsCrypto
import sys


def get_all_feature_flags():
    path_to_portal = Path(os.getenv('PATH_TO_PORTAL'))
    file_name = path_to_portal / "portal-impl" / "src" / "portal.properties"
    file_read = open(file_name, "r")
    text = "feature.flag."

    lines = file_read.readlines()

    epics_in_progress = []
    idx = 0

    for line in lines:
        if text in line:
            epics_in_progress.insert(idx, line)
            idx += 1

    file_read.close()

    all_feature_flags = []
    idx = 0
    for epic in epics_in_progress:
        all_feature_flags.insert(idx, epic[13:epic.find('=')])
        idx += 1

    return all_feature_flags


def get_echo_feature_flags():
    login = manageCredentialsCrypto.get_credentials()
    jira = JIRA("https://issues.liferay.com", basic_auth=login)
    epics_in_progress = jira.search_issues(
        'project = LPS AND (component in (componentsLeadByUser(team-echo))) AND issuetype = Epic and status in (\"In '
        'Development\", \"In QA\", \"In PM Review\", \"Ready for QA\", \"Ready for Product Validation\") AND labels '
        'not in (exclude_from_metrics)')

    echo_feature_flags = []
    idx = 0
    for epic in epics_in_progress:
        echo_feature_flags.insert(idx, epic.key)
        idx += 1

    return echo_feature_flags


def set_feature_flags_to_properties_file(feature_flags_to_enable):
    f = open(properties_file_path, 'a')
    f.write('\n#\n')
    f.write('# Feature flags\n')
    f.write('#\n')

    for issue in feature_flags_to_enable:
        feature_flag = "feature.flag." + issue + "=true\n"
        f.write(feature_flag)

    f.close()


if __name__ == "__main__":
    properties_file_path = ""

    try:
        properties_file_path = sys.argv[1]
    except:
        print("Please provide an existing properties file")
        exit()

    try:
        feature_flag_team = sys.argv[2]
    except:
        feature_flag_team = "all"

    path = Path(properties_file_path)
    if path.is_file():
        if "," in feature_flag_team:
            ff_to_enable = feature_flag_team.split(",")
        elif feature_flag_team == 'echo':
            ff_to_enable = get_echo_feature_flags()
        else:
            ff_to_enable = get_all_feature_flags()

        set_feature_flags_to_properties_file(ff_to_enable)
    else:
        print("Please provide an exiting properties file")
