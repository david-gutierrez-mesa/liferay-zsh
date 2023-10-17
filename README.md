# liferay-zsh
## Description
Oh my zsh plugin with scripts for Liferay development

## Preconditions

### Git
https://github.com/git-guides/install-git

### Java 1.8
Download and install https://www.java.com/es/download/
**Note:** liferay-zsh.plugin.zsh is forcing change to java 1.8

### Oh-My-ZSH
https://github.com/ohmyzsh/ohmyzsh

### GitHub CLI
https://cli.github.com/

### GNU-sed
<details>
<summary>In Mac</summary>
  
```bash
brew install gnu-sed
```
</details>
<details>
<summary>In Linux</summary>
Not needed in Linux
</details>

### Node
<details>
<summary>In Mac</summary>
https://nodejs.org/en/download/package-manager#macos
  
```bash
brew install node
```
</details>
<details>
<summary>In Linux</summary>
https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04
  
```bash
sudo apt update && sudo apt install nodejs && sudo apt install npm
```
</details>

### Liferay projects
Download in $PATH_TO_LIFERAY_MAIN
* Your personal fork of https://github.com/liferay/liferay-portal
* Your personal fork of https://github.com/liferay/liferay-portal-ee
* https://github.com/holatuwol/liferay-intellij

### Set upstream and brianchandotcom for liferay-portal
For that just enter in liferay-portal folder and run:
```bash
git remote add upstream https://github.com/liferay/liferay-portal.git
git remote add brianchandotcom https://github.com/brianchandotcom/liferay-portal.git
```

### Set upstream and brianchandotcom for liferay-portal-ee
For that just enter in liferay-portal-ee folder and run:
```bash
git remote add upstream https://github.com/liferay/liferay-portal-ee.git
git remote add brianchandotcom https://github.com/brianchandotcom/liferay-portal-ee.git
```

### Dependencies for python scripts
#### Install python (if you don't have it)

<details>
<summary>In Mac</summary>
  
```bash
brew install python
```
</details>
<details>
<summary>In Linux</summary>

```bash
sudo apt update && sudo apt install python3
```
</details>

#### Install pip
<details>
<summary>In Mac</summary>
  
Homebrew installs pip pointing to the Homebrew’d Python 3 for you.
</details>
<details>
<summary>In Linux</summary>

```bash
sudo apt install python3-pip
```
</details>

### jira-cli
This is necessary if you want to update Jira from commands like [gitSendTo](https://github.com/david-gutierrez-mesa/liferay-zsh/blob/master/functions/gitSendTo)

Install it with 
```bash
sudo npm install -g jira-cli 
```

Configure it with
```bash
sudo jira config
```

**More info at** https://www.npmjs.com/package/jira-cli

### MySQL
Install it from here https://dev.mysql.com/downloads/file/?id=503070

Set same user and password you have in your .liferay-zsh.config file

### Coreutils
<details>
<summary>In Mac</summary>
  
```bash
brew install coreutils
```
</details>
<details>
<summary>In Linux</summary>

```bash
sudo apt-get update -y && sudo apt-get install -y coreutils
```
</details>


## liferay-zsh installation

In this section, we describe how to install liferay-zsh plugin for oh-my-zsh

### Create installation path and clone repo
As with any zsh plugin we need to create a specific structure to place our liferay-zsh plugin.

These are the steps we should follow:
1. Create a custom folder to place your ZSH customizations. You can create this directory wherever you want and call it as you prefer. For instance MyCustomFolder inside user home
2. Then create a directory called 'plugins' inside your custom directory. 
3. Enter into the plugins directory and do
```bash
gh repo clone david-gutierrez-mesa/liferay-zsh
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

**Note:** To generate a git hub token see https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

### Install Python dependencies
From Liferay ZSH root directory ($ZSH_CUSTOM/plugins/liferay-zsh/) type:
```bash
pip install -r python-scripts/requirements.txt
```

### Reload zsh
Now that all the configuration is done you just need to reload zsh
1. Reload zsh by typing 'zsh' in your terminal. 

Now you are ready to use liferay-zsh plugin

## How to use it
The Liferay ZSH plugin is a set of functions you can call from your Oh My ZSH terminal that are helping you with your daily work inside Liferay.

In order to see all the available functions check [functions](https://github.com/david-gutierrez-mesa/liferay-zsh/tree/master/functions) folder.

To know how to use a function, use the -h parameter. Example:
```bash
gitSendTo -h
```

## References
https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#adding-a-new-plugin

https://github.com/ohmyzsh/ohmyzsh

http://nodegh.io/

## License
[MIT](https://choosealicense.com/licenses/mit/)
