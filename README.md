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
```bash
brew install gnu-sed
```

### Liferay projects
Download in $PATH_TO_LIFERAY_MAIN
* Your personal fork of https://github.com/liferay/liferay-portal
* Your personal fork of https://github.com/liferay/liferay-portal-ee
* https://github.com/holatuwol/liferay-intellij

### Set upstream and brianchandotcom for liferay-portal
For that just enter in liferay-portal fodler and run:
```bash
git remote add upstream https://github.com/liferay/liferay-portal.git <br/>
git remote add brianchandotcom https://github.com/brianchandotcom/liferay-portal.git
```

### Dependencies for testray.py
#### Install python (if you don't have it)
```bash
brew install python
```

#### Install pip
Homebrew installs pip pointing to the Homebrew’d Python 3 for you.

#### Install requests and keyring
```bash
sudo pip install requests<br/>
sudo pip install keyring
```

### jira-cli
This is necessary if you want to update jira from commands like [gitSendTo](https://github.com/david-gutierrez-mesa/liferay-zsh/blob/master/functions/gitSendTo)

Install it with 
```bash
npm install -g jira-cli 
```

Configure it with
```bash
sudo jira config
```

**More info at** https://www.npmjs.com/package/jira-cli

### MySQL
Install it from here https://dev.mysql.com/downloads/file/?id=503070

Set same user and password you have in your .liferay-zsh.config file

## liferay-zsh installation

In this section we describe how to install liferay-zsh plugin for oh-my-zsh

### Create installation path and clone repo
As any zsh plugin we need to create a specific structure to place our liferay-zsh plugin.

These are the steps we should follow:
1. Create a custom folder to place your ZSH customisations. You can create this directory wherever you want and call it as you prefer. For instance MyCustomFolder inside user home
2. Then create a directory call 'plugins' inside your custom directory. 
3. Enter plugins directory and do
```bash
git clone git@github.com:david-gutierrez-mesa/liferay-zsh.git
```

Your file tree should look like this:
> MyCustomFolder<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── plugins<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── liferay-zsh<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── liferay-zsh.plugin.zsh


### Let Oh My ZSH know that we have a new plugin
Now we need to let oh-my-zsh know we have a new plugin. In order to fo that we should tell him  where we placed our plugin and reference it. 

For that we need to:
1. Edit file ~/.zshrc 
2. Search for ZSH_CUSTOM
3. Uncomment line that has ZSH_CUSTOM 
4. To change default value for your path. In our example this line is going to be:
> ZSH_CUSTOM=/Users/dgutierrez/MyCustomFolder
5. In the same file (~/.zshrc) we must search for plugins=
6. Add liferay-zsh into the line that starts with plugins= .Example
> plugins=(git bundler liferay-zsh)
8. Save

### Customize our plugin
You will find in the project a template file call [.liferay-zsh.conf](https://github.com/david-gutierrez-mesa/liferay-zsh/blob/master/.liferay-zsh.config) that you can copy in order to let liferay-zsh plugin know your users and paths.

Steps to follow:
1. Move $ZSH_CUSTOM/plugins/liferay-zsh/.liferay-zsh.conf file to /Users/{youruser}/ folder 
2. Edit /Users/{youruser}/.liferay-zsh.conf and fill al the variables there.

**Note:** to generate a git hub token see https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

### Run install function
Now that all the configuration is done you just need to run installation script
1. Reload zsh by typing 'zsh' in your terminal. 
2. Run installLiferayZSH

Now you are ready to use liferay-zsh plugin

## How to use it
Liferay ZSH plugin is a set of functions you can call from your Oh My ZSH terminal and that are helping you with your daily work inside liferay.

In order to see all the available functions check [functions](https://github.com/david-gutierrez-mesa/liferay-zsh/tree/master/functions) folder.

To know how to use a function, use -h parameter. Example:
```bash
gitSendTo -h
```

## References
https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#adding-a-new-plugin

https://github.com/ohmyzsh/ohmyzsh

http://nodegh.io/