
#General variables
export JIRA_URL="https://issues.liferay.com"
export USER_HOME="$(echo ~)"
export L_ZSH_CONFIG_FILE=$USER_HOME/.liferay-zsh.config

#Load personal variables
. $L_ZSH_CONFIG_FILE

#IntelliJ IDEA
IJ_CLONE_PATH="$USER_HOME/Projects/Tools/liferay-intellij"

ij() {
        ${IJ_CLONE_PATH}/intellij "$@"
}

# JIRA
export JIRA_CONFIG="$USER_HOME/.jira-cli/config.json"

# LIFERAY
export TOMCAT_VERSION="tomcat-9.0.40"
export PATH_TO_PORTAL="$PATH_TO_LIFERAY_MAIN/liferay-portal"
export PATH_TO_BUNDLES="$PATH_TO_LIFERAY_MAIN/bundles"
export PATH_TO_TOMCAT_BIN_FOLDER="$PATH_TO_BUNDLES/$TOMCAT_VERSION/bin"

# PR
alias sf="cd $PATH_TO_PORTAL/portal-impl/ && ant format-source-current-branch && cd $PATH_TO_PORTAL/"
alias sf_local_changes="cd $PATH_TO_PORTAL/portal-impl/ && ant format-source-local-changes & cd $PATH_TO_PORTAL/"

# Poshi
alias poshiValidation="ant -f build-test.xml run-poshi-validation"

alias poshiSF="sf && cd $PATH_TO_PORTAL/modules/ && ../gradlew -b util.gradle formatSourceCurrentBranch && cd .. && poshiValidation"

function poshiSFCommit() {
	if [ -z "$(git status --porcelain)" ]; then
		poshiSF || { echo 'Source Formated failed. Check logs and fix' ; exit 1; }
		if [ -z "$(git status --porcelain)" ]; then
  			echo "There are not Source Formated changes to commit"
		else
  			local LPS_ID=$(git log -1 --pretty=%B | cut -d " " -f 1)
			local message=$(echo $LPS_ID SF)
			git add .
			git commit -m "$message"
			echo "Source formated comited as $message"
		fi
	else
		echo "You have uncommited changes. Commit before do Source Formater"
	fi
}

function runPoshiTest() {
	cd $PATH_TO_PORTAL/
	ant -f build-test.xml run-selenium-test -Dtest.class=$1
	openPoshiResults $1
}

function openPoshiResults() {
	if [ -z "$1" ]; then
                echo "Enter a test to open results"
	else
                local FILENAME=$1:s/#/_/
                if [[ $FILENAME != LocalFile* ]] then
                        echo "Adding LocalFile"
                        FILENAME=LocalFile\."$FILENAME"
                fi
                local PATHTOINDEX=./portal-web/test-results/"$FILENAME"/index.html
        	if [[ -f "$PATHTOINDEX" ]]; then
			open $PATHTOINDEX
		else
    			echo "$PATHTOINDEX does not exist. Can not open test results"
		fi
	fi
}

# Integration
# alias deployModule="gw clean deploy"

function deployModule() {
        if [ -z "$1" ]; then
                gw clean deploy
        else
		cd $PATH_TO_PORTAL/modules/apps/$1
		gw clean deploy
		cd $PATH_TO_PORTAL/
	fi
}

function runIntegrationTest() {
	if [ ! -z "$2" ]; then
		echo cd modules/apps/$2
		cd modules/apps/$2
		if [ $? -ne 0 ]; then
    			echo "Module $2  does not exist in modules/app/"
			exit;
		fi
	fi
	if [ -z "$1" ]; then
		echo gw testIntegration
                gw testIntegration
 	elif [ "$1" = all ]; then
		echo gw testIntegration
		gw testIntegration
	else
		echo testIntegration --tests "*$1*"
		gw testIntegration --tests "*$1*";
	fi
	open $(pwd)/$(basename `pwd`)-test/build/reports/tests/testIntegration/index.html
	if [ $? -ne 0 ]; then
		open $(pwd)/build/reports/tests/testIntegration/index.html
	fi
	if [ ! -z "$2" ]; then
		cd $PATH_TO_PORTAL/
        fi
}

# Jira
function jiraGetIssueSummary() {
	local LPS_ID=$1
	if [ -z "$1" ]; then
		LPS_ID=$(git log -1 --pretty=%B | cut -d " " -f 1)
	fi
	echo "$(jira show $LPS_ID)" | grep Summary | sed 's/^.\{23\}//' | sed 's/.\{2\}$//'
}

# Git
alias gs="git status"
alias gl="git log"

alias gitClean="git clean -fd && git reset --hard"
alias gitMaster="git checkout master"
alias gitRebase="git rebase upstream/master"
alias gitRebaseBrian="git rebase brian/master"
alias gitRebaseAbort="git rebase --abort && unset PR_NUMBER"
alias gitRebaseContinue="git rebase --continue"

alias gcxdf="git clean -xdf -e '**/*.iml' -e '.gradle/gradle.properties' -e '.idea' -e '.m2' -e \"app.server.$USER.properties\" -e \"build.$USER.properties\""

function gitDeleteRemoteBranch() {
	local BRANCH_TO_DELETE=$1
        if [ -z "$1" ]; then
		BRANCH_TO_DELETE=$(git branch --show-current)
		if [ "$BRANCH_TO_DELETE"  = "master" ]; then
			echo 'You can not delete master branch';
			return;
		fi
	else
        	echo 'Branch not set. Removing current one remotlley';
	fi
	echo 'Removing remote branch named '$BRANCH_TO_DELETE 'from repo liferay-portal of user'$GITHUB_USER;
	git ls-remote --heads --exit-code git@github.com:$GITHUB_USER/liferay-portal.git $BRANCH_TO_DELETE;
	if [ $? -eq 0 ]; then
		git push origin --delete $BRANCH_TO_DELETE
	else
		echo 'Remote branch does not exists. Nothing to do';
	fi
}

function gitSendTo() {
	local skipSF="false"
	local updatePullRequest="true"
	while [ "$1" != "" ]; do
		case $1 in
			-h | -help)
				echo "gitSendTo [options]"
				echo " "
				echo "options:"
				echo "-h | -help,				show brief help"
				echo "-u,	       				git use to send the PR. Mandatory"
				echo "-supr | -supdatePullRequest,		Don't update PR with info get from LPS extracted from last commit"
				echo "-uj,              			updates also Jira ticket from last commit. If you have more than one LPS you must update the other manually"
				echo "-ssf | -skipSF,     			skip Poshi validation and Source Formater"
				exit 0
      				;;
                	-u)
				shift
				username="$1"
				;;
                        -supr | -skipUpdatePullRequest)
				updatePullRequest="false"
				;;
                        -uj)
				updateJira="true"
				;;
			-ssf | -skipSF)
				skipSF="true"
                                ;;
                esac
		shift
        done
        if [ -z "$username" ]; then
	        echo "Add a git user please"
                exit 0;
	fi
	if [ -z "$(git status --porcelain)" ]; then
		if [ "$skipSF" = "true" ]; then
			echo "Skipping Poshi Validationa nd SF"
		else
			poshiSFCommit || { echo 'Impossible to commit. Source Formated failed' ; return; }
		fi
		local prOptions=""
		if [ "$updatePullRequest" = "true" ]; then
			local LPS_ID=$(git log -1 --pretty=%B | cut -d " " -f 1)
			local LPS_SUMMARY=$(jiraGetIssueSummary $LPS_ID)
			local PR_TITLE="$LPS_ID $LPS_SUMMARY"
			local PR_MESSAGE="$JIRA_URL/browse/$LPS_ID"
			gitDeleteRemoteBranch;
                	gh pr -s $username $prOptions --title $PR_TITLE --description $PR_MESSAGE
		else
			echo "Skipping Pull Request update with Jira info"
			gitDeleteRemoteBranch;
      gh pr -s $username
    fi
	else
		echo "You have uncommited changes. Commit before try to send"
	fi
}

function gitForcePush() {
        if [ -z "$(git status --porcelain)" ]; then
		local BRANCH_NAME=$1
                if [ -z "$1" ]; then
			BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD| cut -d " " -f 1)
                fi
		poshiSFCommit || { echo 'Impossible to commit. Source Formated failed' ; return; }
		echo "Force pushing branch " $BRANCH_NAME
                git push --set-upstream -f origin $BRANCH_NAME
        else
                echo "You have uncommited changes. Commit before try to send"
        fi
}

alias gitFetchBrians="git fetch brian master"
alias gitSendToMe="gitSendTo -u $GITHUB_USER"
alias gitSendToBrian="gitSendTo -u brianchandotcom"
alias gitSendToEchoUser="gitSendTo -u liferay-echo"

alias gitGetFromEchouser="gh pr -u liferay-echo"

function gitGetPRTitle() {
	if [ -z "$1" ]; then
                echo "Enter a PR number"
        else
		local FROM_USER=$GITHUB_USER
                if [ -n "$2" ]; then
                        FROM_USER=$2
                fi
		local PR_TITLE=$(gh pr -u $FROM_USER --info $1 2> /dev/null | sed -n 1p | cut -d'@' -f 1| sed "s/^[^ ]* //" | gsed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
		echo $PR_TITLE
        fi
}

function gitGetPRSender() {
        if [ -z "$1" ]; then
                echo "Enter a PR number"
        else
		local FROM_USER=$GITHUB_USER
                if [ -n "$2" ]; then
                        FROM_USER=$2
                fi
                local PR_SENDER=$(gh pr -u $FROM_USER --info $1 2> /dev/null | sed -n 1p | cut -d'(' -f 1| sed "s/^[^@]* //" | gsed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
                echo $PR_SENDER
        fi
}

function gitGetPRMessage() {
        if [ -z "$1" ]; then
                echo "Enter a PR number"
        else
		local FROM_USER=$GITHUB_USER
                if [ -n "$2" ]; then
                        FROM_USER=$2
                fi
                local PR_MESSAGE=$(gh pr -u $FROM_USER --info $1 2> /dev/null | sed '1d' | grep -v '^Mergeable' | gsed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
                echo $PR_MESSAGE
        fi
}

function gitGetPRMessageWitSender() {
        if [ -z "$1" ]; then
                echo "Enter a PR number"
        else
                local PR_MESSAGE=$(gitGetPRMessage $1 $2)
		local PR_SENDER=$(gitGetPRSender $1 $2)
                echo "$PR_MESSAGE\ncc/ $PR_SENDER"
        fi
}

function gitGetLastPRnumber() {
	gh pr --list -u $GITHUB_USER --sort created --direction desc | gsed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | sed -n 7p | cut -d'(' -f 1| sed "s/^[^#]* //" | cut -d' ' -f 1
}

function gitCloseRebasedPR() {
        if [ -z "$2" ]; then
                echo "Enter a PR number to be closed and a PR to comment the rebase"
        else
		local FROM_USER=$GITHUB_USER
                if [ -n "$3" ]; then
                        FROM_USER=$3
                fi
		local PR_TO_CLOSE=$1
		local PR_REBASED=$2
		gh pr -u $FROM_USER $PR_TO_CLOSE --close || { echo "Impossible close PR $PR_REBASED" ; return; }
		gh pr -u $FROM_USER $PR_TO_CLOSE --comment "Rebased. See $PR_REBASED"
        fi
}

function gitGetRebaseAndSendPR() {
	if [ -z "$1" ]; then
                echo "Enter a PR number"
        else
		PR_NUMBER=$1
		local FROM_USER=$GITHUB_USER
                if [ -n "$2" ]; then
                        FROM_USER=$2
                        echo 'Getting PR' $1 'from user' $2
                fi
		gitMaster
		gh pr -u $FROM_USER $PR_NUMBER || { echo 'Impossible to get PR ' $PR_NUMBER ' from user ' $FROM_USER ; return; }
		echo "Rebasing"
		gitRebase || { echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR' ; return; }
		echo "Running Poshi validations"
		poshiSFCommit || { echo 'Impossible to commit. Source Formated failed' ; return; }
		echo "Sending to me"
		local PR_TITLE=$(gitGetPRTitle $PR_NUMBER $FROM_USER)
		local PR_MESSAGE=""
                if [ "$FROM_USER"  = "$GITHUB_USER" ]; then
                        PR_MESSAGE=$(gitGetPRMessage $PR_NUMBER $FROM_USER)
                else
                        PR_MESSAGE=$(gitGetPRMessageWitSender $PR_NUMBER $FROM_USER)
                fi
	        gh pr -s $GITHUB_USER --title "$PR_TITLE" --description "$PR_MESSAGE"
		local OPENED_PR=$(gitGetLastPRnumber)
		gitCloseRebasedPR $PR_NUMBER $OPENED_PR $FROM_USER
		git checkout pr-$PR_NUMBER
		unset PR_NUMBER
	fi
}

function gitRebaseContinueAndSendPR() {
	if [ -z "$PR_NUMBER" ]; then
                echo "You didn' run gitGetRebaseAndSendPR before"
        else
        	gitRebaseContinue || { echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR' ; exit 1; }
		echo "Running Poshi validations"
                poshiSFCommit || { echo 'Impossible to commit. Source Formated failed' ; return; }
                echo "Sending to me"
                local PR_TITLE=$(gitGetPRTitle $PR_NUMBER $FROM_USER)
                local PR_MESSAGE=""
                if [ "$FROM_USER"  = "$GITHUB_USER" ]; then
                        PR_MESSAGE=$(gitGetPRMessage $PR_NUMBER $FROM_USER)
                else
                        PR_MESSAGE=$(gitGetPRMessageWitSender $PR_NUMBER $FROM_USER)
                fi
                gh pr -s $GITHUB_USER --title "$PR_TITLE" --description "$PR_MESSAGE"
                local OPENED_PR=$(gitGetLastPRnumber)
                gitCloseRebasedPR $PR_NUMBER $OPENED_PR $FROM_USER
                git checkout pr-$PR_NUMBER
                unset PR_NUMBER
	fi
}

function gitGetFailingPRAndSendToBrian() {
        if [ -z "$1" ]; then
                echo "Enter a PR number"
        else
		local FROM_USER=$GITHUB_USER
	        if [ -n "$2" ]; then
        	        FROM_USER=$2
			echo 'Getting PR' $1 'from user' $2
        	fi
                PR_NUMBER_TO_BCHAN=$1
                gitMaster
                gitFetchBrians
		gh pr -u $FROM_USER  $PR_NUMBER_TO_BCHAN || { echo 'Impossible to get PR ' $PR_NUMBER_TO_BCHAN ' from user ' $FROM_USER ; return; }
                echo "Rebasing"
                gitRebaseBrian || { echo 'Rebase failed. Fix rebase and continue manually with gitRebaseBriansContinueAndSendPR' ; return; }
                echo "Running Poshi validations"
                poshiSFCommit || { echo 'Impossible to commit. Source Formated failed' ; return; }
                echo "Sending to Brian"
                local PR_TITLE=$(gitGetPRTitle $PR_NUMBER_TO_BCHAN $FROM_USER)
		if [ "$FROM_USER"  = "$GITHUB_USER" ]; then
			local PR_MESSAGE=$(gitGetPRMessage $PR_NUMBER_TO_BCHAN $FROM_USER)
		else
			local PR_MESSAGE=$(gitGetPRMessageWitSender $PR_NUMBER_TO_BCHAN $FROM_USER)
		fi
                gh pr -s brianchandotcom --title "$PR_TITLE" --description "$PR_MESSAGE"
                unset PR_NUMBER_TO_BCHAN
        fi
}

function gitRebaseBriansContinueAndSendPR() {
        if [ -z "$PR_NUMBER_TO_BCHAN" ]; then
                echo "You didn' run gitGetFailingPRAndSendToBrian before"
        else
                gitRebaseContinue || { echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR' ; return; }
                echo "Running Poshi validations"
                poshiSFCommit || { echo 'Impossible to commit. Source Formated failed' ; return; }
                echo "Sending to Brian"
                local PR_TITLE=$(gitGetPRTitle $PR_NUMBER_TO_BCHAN)
                local PR_MESSAGE=$(gitGetPRMessageWitSender $PR_NUMBER_TO_BCHAN)
                gh pr -s brianchandotcom --title "$PR_TITLE" --description "$PR_MESSAGE"
                unset PR_NUMBER_TO_BCHAN
        fi
}

# Eng
alias updateGitLiferay="cd $PATH_TO_PORTAL/ && gco master && gcxdf && git fetch upstream master && git pull upstream master && git push origin head"

alias updateGitLiferayEE="cd $PATH_TO_DXP_PORTAL/ && gco master && gcxdf && git fetch upstream master && git pull upstream master && git push origin head"

alias mountBundleCE="cd $PATH_TO_PORTAL/ && rm -rf ../bundles && ant setup-profile-portal && ant all && cp ../util-files/test.$USER.properties ./ && gitClean && ij"

alias updateBundleCE="cd $PATH_TO_PORTAL/ && ant all && cp ../util-files/test.$USER.properties ./ && gitClean && ij"

alias mountBundleEE="cd $PATH_TO_DXP_PORTAL/ && rm -rf ../bundles && ant setup-profile-dxp && ant all && cp ../util-files/test.$USER.properties ./ && gitClean && ij"

alias startLiferay="cd $PATH_TO_TOMCAT_BIN_FOLDER/ && ./catalina.sh run"

alias stopLiferay="cd $PATH_TO_TOMCAT_BIN_FOLDER/ && ./catalina.sh stop && cd $PATH_TO_LIFERAY_MAIN"

alias updateCleanBundleCEStartLiferay="updateGitLiferay && mountBundleCE && startLiferay"

alias updateCleanBundleEEStartLiferay="updateGitLiferayEE && mountBundleEE && startLiferay"

alias updateCEStartLiferay="updateGitLiferay && updateBundleCE && startLiferay"

alias restartLiferay="stopLiferay && startLiferay"

function updateAndDeployExistingBranch() {
        updateGitLiferay && git checkout $1 && git rebase upstream/master && mountBundleCE && startLiferay
}
