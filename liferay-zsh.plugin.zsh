#General variables
export JIRA_URL="https://issues.liferay.com"
export USER_HOME="$(echo ~)"
export L_ZSH_CONFIG_FILE=$USER_HOME/.liferay-zsh.config
export LIFERAY_ZSH_INSTALLATION_PATH="${0%/*}"

#Load personal variables
. $L_ZSH_CONFIG_FILE

#ANT
export ANT_OPTS="-Xmx2560m"

# JIRA
JIRA_CONFIG="$USER_HOME/.jira-cli/config.json"
export JIRA_CONFIG

# JAVA
JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export JAVA_HOME

# LIFERAY
export TOMCAT_VERSION="tomcat-9.0.43"
export PATH_TO_PORTAL="$PATH_TO_LIFERAY_MAIN/liferay-portal"
export PATH_TO_DXP_PORTAL="$PATH_TO_LIFERAY_MAIN/liferay-portal-ee"
export PATH_TO_BUNDLES="$PATH_TO_LIFERAY_MAIN/bundles"
export PATH_TO_TOMCAT_BIN_FOLDER="$PATH_TO_BUNDLES/$TOMCAT_VERSION/bin"
export PORTAL_DATABASE_NAME="lportal"

# MySql
export MYSQL_HOME="/usr/local/mysql"
export PATH=$MYSQL_HOME/bin:$PATH

#IntelliJ IDEA
IJ_CLONE_PATH="$PATH_TO_LIFERAY_MAIN/liferay-intellij"

ij() {
  ${IJ_CLONE_PATH}/intellij "$@"
}

# PR
alias sf='cd $PATH_TO_PORTAL/portal-impl/ && ant format-source-current-branch && cd $PATH_TO_PORTAL/'
alias sf_local_changes='cd $PATH_TO_PORTAL/portal-impl/ && ant format-source-local-changes & cd $PATH_TO_PORTAL/'

# Testing tools
alias testrayResultsFromPR='${LIFERAY_ZSH_INSTALLATION_PATH}/testing-tools/testray.py'

#Load functions
fpath=("${ZSH_INSTALLATION_PATH}/functions" "${fpath[@]}")
autoload -Uz $fpath[1]/*(.:t)

# Poshi
alias poshiValidation="ant -f build-test.xml run-poshi-validation"
alias poshiSF='sf && cd $PATH_TO_PORTAL/modules/ && ../gradlew -b util.gradle formatSourceCurrentBranch && cd .. && poshiValidation'

function poshiSFCommit() {
  if [ -z "$(git status --porcelain)" ]; then
    poshiSF || {
      echo 'Source Formated failed. Check logs and fix'
      exit 1
    }
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
    if [[ $FILENAME != LocalFile* ]]; then
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
      exit
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
    gw testIntegration --tests "*$1*"
  fi
  open $(pwd)/$(basename $(pwd))-test/build/reports/tests/testIntegration/index.html
  if [ $? -ne 0 ]; then
    open $(pwd)/build/reports/tests/testIntegration/index.html
  fi
  if [ ! -z "$2" ]; then
    cd $PATH_TO_PORTAL/
  fi
}

# Git
alias gs="git status"
alias gl="git log"

alias gitRebaseBrian="git rebase brian/master"
alias gitRebaseAbort="git rebase --abort && unset PR_NUMBER"
alias gitRebaseContinue="git rebase --continue"

function gitDeleteRemoteBranch() {
  local BRANCH_TO_DELETE=$1
  if [ -z "$1" ]; then
    BRANCH_TO_DELETE=$(git branch --show-current)
    if [ "$BRANCH_TO_DELETE" = "master" ]; then
      echo 'You can not delete master branch'
      return
    fi
  else
    echo 'Branch not set. Removing current one remotlley'
  fi
  echo 'Removing remote branch named '$BRANCH_TO_DELETE 'from repo liferay-portal of user'$GITHUB_USER
  git ls-remote --heads --exit-code git@github.com:$GITHUB_USER/liferay-portal.git $BRANCH_TO_DELETE
  if [ $? -eq 0 ]; then
    git push origin --delete $BRANCH_TO_DELETE
  else
    echo 'Remote branch does not exists. Nothing to do'
  fi
}

alias gitFetchBrians="git fetch brian master"
alias gitSendToMe="gitSendTo -u $GITHUB_USER"
alias gitSendToBrian="gitSendTo -u brianchandotcom -suj"
alias gitSendToEchoUser="gitSendTo -u liferay-echo"

alias gitGetFromEchoUser="gh pr -u liferay-echo"

function gitGetPRTitle() {
  if [ -z "$1" ]; then
    echo "Enter a PR number"
  else
    local FROM_USER=$GITHUB_USER
    if [ -n "$2" ]; then
      FROM_USER=$2
    fi
    local PR_TITLE
    PR_TITLE=$(gh pr -u $FROM_USER --info $1 2>/dev/null | sed -n 1p | cut -d'@' -f 1 | sed "s/^[^ ]* //" | gsed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    echo "$PR_TITLE"
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
    local PR_SENDER
    PR_SENDER=$(gh pr -u $FROM_USER --info $1 2>/dev/null | sed -n 1p | cut -d'(' -f 1 | sed "s/^[^@]* //" | gsed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    echo "$PR_SENDER"
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
    local PR_MESSAGE
    PR_MESSAGE=$(gh pr -u $FROM_USER --info $1 2>/dev/null | sed '1d' | grep -v '^Mergeable' | gsed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    echo "$PR_MESSAGE"
  fi
}

function gitGetPRMessageWitSender() {
  if [ -z "$1" ]; then
    echo "Enter a PR number"
  else
    local PR_MESSAGE
    PR_MESSAGE=$(gitGetPRMessage $1 $2)
    local PR_SENDER
    PR_SENDER=$(gitGetPRSender $1 $2)
    echo "$PR_MESSAGE\ncc/ $PR_SENDER"
  fi
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
    gh pr -u $FROM_USER $PR_TO_CLOSE --close || {
      echo "Impossible close PR $PR_REBASED"
      return
    }
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
    gh pr -u $FROM_USER $PR_NUMBER || {
      echo 'Impossible to get PR ' $PR_NUMBER ' from user ' $FROM_USER
      return
    }
    echo "Rebasing"
    gitRebase || {
      echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR'
      return
    }
    echo "Running Poshi validations"
    poshiSFCommit || {
      echo 'Impossible to commit. Source Formated failed'
      return
    }
    echo "Sending to me"
    local PR_TITLE
    PR_TITLE=$(gitGetPRTitle $PR_NUMBER $FROM_USER)
    local PR_MESSAGE=""
    if [ "$FROM_USER" = "$GITHUB_USER" ]; then
      PR_MESSAGE=$(gitGetPRMessage $PR_NUMBER $FROM_USER)
    else
      PR_MESSAGE=$(gitGetPRMessageWitSender $PR_NUMBER $FROM_USER)
    fi
    gh pr -s $GITHUB_USER --title "$PR_TITLE" --description "$PR_MESSAGE"
    local OPENED_PR
    OPENED_PR=$(gitGetLastPRnumber)
    gitCloseRebasedPR $PR_NUMBER $OPENED_PR $FROM_USER
    git checkout pr-$PR_NUMBER
    unset PR_NUMBER
  fi
}

function gitRebaseContinueAndSendPR() {
  if [ -z "$PR_NUMBER" ]; then
    echo "You didn' run gitGetRebaseAndSendPR before"
  else
    gitRebaseContinue || {
      echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR'
      exit 1
    }
    echo "Running Poshi validations"
    poshiSFCommit || {
      echo 'Impossible to commit. Source Formated failed'
      return
    }
    echo "Sending to me"
    local PR_TITLE=$(gitGetPRTitle $PR_NUMBER $FROM_USER)
    local PR_MESSAGE=""
    if [ "$FROM_USER" = "$GITHUB_USER" ]; then
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
    gh pr -u $FROM_USER $PR_NUMBER_TO_BCHAN || {
      echo 'Impossible to get PR ' $PR_NUMBER_TO_BCHAN ' from user ' $FROM_USER
      return
    }
    echo "Rebasing"
    gitRebaseBrian || {
      echo 'Rebase failed. Fix rebase and continue manually with gitRebaseBriansContinueAndSendPR'
      return
    }
    echo "Running Poshi validations"
    poshiSFCommit || {
      echo 'Impossible to commit. Source Formated failed'
      return
    }
    echo "Sending to Brian"
    local PR_TITLE=$(gitGetPRTitle $PR_NUMBER_TO_BCHAN $FROM_USER)
    if [ "$FROM_USER" = "$GITHUB_USER" ]; then
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
    gitRebaseContinue || {
      echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR'
      return
    }
    echo "Running Poshi validations"
    poshiSFCommit || {
      echo 'Impossible to commit. Source Formated failed'
      return
    }
    echo "Sending to Brian"
    local PR_TITLE
    PR_TITLE=$(gitGetPRTitle $PR_NUMBER_TO_BCHAN)
    local PR_MESSAGE
    PR_MESSAGE=$(gitGetPRMessageWitSender $PR_NUMBER_TO_BCHAN)
    gh pr -s brianchandotcom --title "$PR_TITLE" --description "$PR_MESSAGE"
    unset PR_NUMBER_TO_BCHAN
  fi
}

# Eng
alias startLiferay="cd $PATH_TO_TOMCAT_BIN_FOLDER/ && ./catalina.sh jpda run"

alias stopLiferay="cd $PATH_TO_TOMCAT_BIN_FOLDER/ && ./catalina.sh stop && cd $PATH_TO_LIFERAY_MAIN"

alias updateCleanBundleCEStartLiferay="updateGitLiferay && mountBundle && startLiferay"

alias updateCleanBundleEEStartLiferay="updateGitLiferay -dxp && mountBundle -dxp && startLiferay"

alias updateCEStartLiferay="updateGitLiferay && mountBundle -u && startLiferay"

alias updateEEStartLiferay="updateGitLiferay -dxp && mountBundle -dxp -u && startLiferay"

alias restartLiferay="stopLiferay && sleep 300 && startLiferay"
