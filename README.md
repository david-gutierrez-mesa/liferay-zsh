# liferay-zsh
## Description
Oh my zsh plugin with scripts for Liferay development

## Preconditions

### Java 1.8
Download and install https://www.java.com/es/download/
**Note:** liferay-zsh.plugin.zsh is forcing change to java 1.8

### Oh-My-ZSH
https://github.com/ohmyzsh/ohmyzsh

### Node GH
http://nodegh.io/

### GNU-sed
> brew install gnu-sed

### Liferay projects
Download in $PATH_TO_LIFERAY_MAIN
* Your personal fork of https://github.com/liferay/liferay-portal
* Your personal fork of https://github.com/liferay/liferay-portal-ee
* https://github.com/holatuwol/liferay-intellij

### Set upstream and brianchandotcom for liferay-portal
For that just enter in liferay-portal fodler and run:
> git remote add upstream https://github.com/liferay/liferay-portal.git <br/>
> git remote add brianchandotcom https://github.com/brianchandotcom/liferay-portal.git

### Dependencies for testray.py
#### Install python (if you don't have it)
> brew install python

#### Install pip
Homebrew installs pip pointing to the Homebrew’d Python 3 for you.

#### Install requests and keyring
> sudo pip install requests<br/>
> sudo pip install keyring

### jira-cli
This is necessary if you want to update jira from commands like [gitSendTo](https://github.com/david-gutierrez-mesa/liferay-zsh/blob/master/functions/gitSendTo)

Install it with 
> npm install -g jira-cli 

Configure it with
> sudo jira config

**More info in** https://www.npmjs.com/package/jira-cli

### MySQL
Install it from here https://dev.mysql.com/downloads/file/?id=503070

Set same user and password you have in your .liferay-zsh.config file

## liferay-zsh installation

Create a custom folder to place your ZSH customisations. Then Create a plugins directory inside your custom directory.

Enter plugins directory and do

git clone git@github.com:david-gutierrez-mesa/liferay-zsh.git

Your file tree should look like this:
> $ZSH_CUSTOM<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── plugins<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── liferay-zsh<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── liferay-zsh.plugin.zsh

Set ZSH_CUSTOM value to your custom folder and add liferay-zsh plugin in ~/.zshrc file
* Edit file ~/.zshrc
* Set ZSH_CUSTOM value to your custom folder
* Uncomment line that has ZSH_CUSTOM
* To change default value for your path
* Add liferay-zsh into the line that starts with plugins=
* Example plugins=(git bundler liferay-zsh)
* Save

Move $ZSH_CUSTOM/plugins/liferay-zsh/.liferay-zsh.conf file to /Users/{youruser}/ folder

Edit /Users/{youruser}/ .liferay-zsh.conf and fill al the variables there.

**Note:** to generate a token see https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

Reload zsh by typing 'zsh' in your terminal.

Run installLiferayZSH

## References
https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#adding-a-new-plugin

https://github.com/ohmyzsh/ohmyzsh

http://nodegh.io/