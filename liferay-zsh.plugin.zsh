#General variables
export USER_HOME="$(echo ~)"
export L_ZSH_CONFIG_FILE=$USER_HOME/.liferay-zsh.config
export LIFERAY_ZSH_INSTALLATION_PATH="${0%/*}"
export LIFERAY_ZSH_DEPLOYMENTS_PATH=$LIFERAY_ZSH_INSTALLATION_PATH/deployments

#Load personal variables
. $L_ZSH_CONFIG_FILE

#ANT and GRADLE
case $(uname) in
  Darwin)
    export ANT_OPTS="-Xmx2560m"
  ;;
  Linux)
    export ANT_OPTS="-Xms8192M -Xmx8192M"
    export GRADLE_OPTS="-Xms8192M -Xmx8192M"
  ;;
esac

# JIRA
JIRA_CONFIG="$USER_HOME/.jira-cli/config.json"
export JIRA_CONFIG
export JIRA_URL="https://issues.liferay.com"

# JAVA
if [ -z "$JAVA_HOME" ]; then
  case $(uname) in
    Darwin)
      JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
      export JAVA_HOME
    ;;
    Linux)
      JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
      export JAVA_HOME
    ;;
  esac
fi

# LIFERAY
export LIFERAY_GITHUB_USER="liferay"
export PATH_TO_PORTAL="$PATH_TO_LIFERAY_MAIN/liferay-portal"
export PATH_TO_DXP_PORTAL="$PATH_TO_LIFERAY_MAIN/liferay-portal-ee"
export PATH_TO_BUNDLES="$PATH_TO_LIFERAY_MAIN/bundles"
export PORTAL_DATABASE_NAME="lportal"
export REPO="liferay-portal"
export REPO_DXP="liferay-portal-ee"

#Poshi automation
export CHROMIUM_DOWNLOAD_PATH="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Mac%2F800208%2Fchrome-mac.zip?generation=1597949046060527&alt=media"
export CHROMIUM_INSTALLATION_PATH=$LIFERAY_ZSH_DEPLOYMENTS_PATH/chrome-mac

# MySql
export MYSQL_HOME="/usr/local/mysql"
export PATH=$MYSQL_HOME/bin:$PATH

#IntelliJ IDEA
export IJ_CLONE_PATH="$PATH_TO_LIFERAY_MAIN/liferay-intellij"

# Testing tools
alias testrayResultsFromPR='python ${LIFERAY_ZSH_INSTALLATION_PATH}/testing-tools/testray.py'

#Load functions
fpath=("${LIFERAY_ZSH_INSTALLATION_PATH}/functions" "${fpath[@]}")
autoload -Uz $fpath[1]/*(.:t)

# Git
alias gs="git status"
alias gl="git log"

alias gitRebaseAbort="git rebase --abort && unset PR_NUMBER"

alias gitSendToMe="gitSendTo -u $GITHUB_USER"
alias gitSendToBrian="gitSendTo -u brianchandotcom -suj"
alias gitSendToEchoUser="gitSendTo -u liferay-echo"

function gitRebaseContinueAndSendPR() {
  if [ -z "$PR_NUMBER" ]; then
    echo "You didn' run gitGetRebaseAndSendPR before"
  else
    gitRebaseContinue || {
      echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR'
      return 1
    }
    echo "Running Poshi validations"
    poshiSFCommit || {
      echo 'Impossible to commit. Source Formatted failed'
      return 1
    }
    echo "Sending to me"
    local PR_TITLE
    PR_TITLE=$(gitGetPRTitle -pr "$PR_NUMBER" -u "$FROM_USER")
    local PR_MESSAGE=""
    if [ "$FROM_USER" = "$GITHUB_USER" ]; then
      PR_MESSAGE=$(gitGetPRMessage -pr "$PR_NUMBER" -u "$FROM_USER")
    else
      PR_MESSAGE=$(gitGetPRMessageWitSender -pr "$PR_NUMBER" -u "$FROM_USER")
    fi
    gh pr -s "$GITHUB_USER" --title "$PR_TITLE" --description "$PR_MESSAGE"
    local OPENED_PR
    OPENED_PR=$(gitGetLastPRnumber)
    gitCloseRebasedPR -prtc "$PR_NUMBER" -prrb "$OPENED_PR" -u "$FROM_USER"
    git checkout pr-"$PR_NUMBER"
    unset PR_NUMBER

  fi
}

function gitRebaseBriansContinueAndSendPR() {
  if [ -z "$PR_NUMBER_TO_BCHAN" ]; then
    echo "You didn't run gitGetFailingPRAndSendToBrian before"
  else
    gitRebaseContinue || {
      echo 'Rebase failed. Fix rebase and continue manually with gitRebaseContinueAndSendPR'
      return
    }
    echo "Running Poshi validations"
    poshiSFCommit || {
      echo 'Impossible to commit. Source Formatter failed'
      return
    }
    echo "Sending to Brian"
    local PR_TITLE
    PR_TITLE=$(gitGetPRTitle -pr "$PR_NUMBER_TO_BCHAN")
    local PR_MESSAGE
    PR_MESSAGE=$(gitGetPRMessageWitSender -pr "$PR_NUMBER_TO_BCHAN")
    gh pr -s brianchandotcom --title "$PR_TITLE" --description "$PR_MESSAGE"
    unset PR_NUMBER_TO_BCHAN
  fi
}

