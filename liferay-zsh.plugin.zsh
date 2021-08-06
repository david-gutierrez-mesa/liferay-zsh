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

# Testing tools
alias testrayResultsFromPR='python ${LIFERAY_ZSH_INSTALLATION_PATH}/testing-tools/testray.py'

#Load functions
fpath=("${ZSH_INSTALLATION_PATH}/functions" "${fpath[@]}")
autoload -Uz $fpath[1]/*(.:t)

# Poshi
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

alias gitRebaseAbort="git rebase --abort && unset PR_NUMBER"

alias gitSendToMe="gitSendTo -u $GITHUB_USER"
alias gitSendToBrian="gitSendTo -u brianchandotcom -suj"
alias gitSendToEchoUser="gitSendTo -u liferay-echo"

alias gitGetFromEchoUser="gh pr -u liferay-echo"

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
    local PR_TITLE=$(gitGetPRTitle -pr $PR_NUMBER -u $FROM_USER)
    local PR_MESSAGE=""
    if [ "$FROM_USER" = "$GITHUB_USER" ]; then
      PR_MESSAGE=$(gitGetPRMessage -pr $PR_NUMBER -u $FROM_USER)
    else
      PR_MESSAGE=$(gitGetPRMessageWitSender -pr $PR_NUMBER -u $FROM_USER)
    fi
    gh pr -s $GITHUB_USER --title "$PR_TITLE" --description "$PR_MESSAGE"
    local OPENED_PR=$(gitGetLastPRnumber)
    gitCloseRebasedPR -prtc $PR_NUMBER -prrb $OPENED_PR -u $FROM_USER
    git checkout pr-$PR_NUMBER
    unset PR_NUMBER

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
    PR_TITLE=$(gitGetPRTitle -pr $PR_NUMBER_TO_BCHAN)
    local PR_MESSAGE
    PR_MESSAGE=$(gitGetPRMessageWitSender -pr $PR_NUMBER_TO_BCHAN)
    gh pr -s brianchandotcom --title "$PR_TITLE" --description "$PR_MESSAGE"
    unset PR_NUMBER_TO_BCHAN
  fi
}

# Eng
alias updateCleanBundleCEStartLiferay="updateGitLiferay && mountBundle -s"

alias updateCleanBundleEEStartLiferay="updateGitLiferay -dxp && mountBundle -dxp -s"

alias updateCEStartLiferay="updateGitLiferay && mountBundle -u -s"

alias updateEEStartLiferay="updateGitLiferay -dxp && mountBundle -dxp -u -s"

