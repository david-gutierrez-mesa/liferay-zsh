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

### Liferay projects
Download in $PATH_TO_LIFERAY_MAIN
* Your personal fork of https://github.com/liferay/liferay-portal
* Your personal fork of https://github.com/liferay/liferay-portal-ee
* https://github.com/holatuwol/liferay-intellij

### Set upstream and brianchandotcom
For that just run:
> git remote add upstream https://github.com/liferay/liferay-portal.git <br/>
> git remote add brianchandotcom https://github.com/brianchandotcom/liferay-portal.git

## liferay-zsh installation

Create a custom folder to place your ZSH customisations. Then Create a plugins directory inside your custom directory.

Enter plugins directory and do

git clone git@github.com:david-gutierrez-mesa/liferay-zsh.git

Your file tree should look like this:
> $ZSH_CUSTOM<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── plugins<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── liferay-zsh<br/>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── liferay-zsh.plugin.zsh

Set ZSH_CUSTOM value to your custom folder and add liferay-zsh plugin in
* Edit file 
* Set ZSH_CUSTOM value to your custom folder
* Uncomment line that has ZSH_CUSTOM
* To change default value for your path
* Add liferay-zsh plug in
* Add liferay-zsh into the line that starts with plugins=
* Example plugins=(git bundler liferay-zsh)
* Save

Move $ZSH_CUSTOM/plugins/liferay-zsh/.liferay-zsh.conf file to /Users/{youruser}/ folder

Edit /Users/{youruser}/ .liferay-zsh.conf and fill al the variables there.

**Note:** to generate a token see https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

Reload zsh by typing 'zsh' in your terminal

## References
https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#adding-a-new-plugin

https://github.com/ohmyzsh/ohmyzsh

http://nodegh.io/