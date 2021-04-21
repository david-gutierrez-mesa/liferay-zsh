# liferay-zsh
## Description
Oh my zsh plugins for Liferay development

## liferay-zsh instalación

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

Note: to generate a token see https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

Reload zsh by typing 'zsh' in your terminal

## References
https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#adding-a-new-plugin