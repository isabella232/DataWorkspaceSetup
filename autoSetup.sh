#!/bin/bash
echo
echo -----------------------------------------------------------------
echo This program helps prepare a new OSX computer for data engineers.
echo -----------------------------------------------------------------
echo

# Originally, I made this to be used on the OSX.
# Then I adapted it to work in a docker container.
# Then we decided to just run is on the OSX again; it has to be reworked,
# but it'll probably be easier that way.



echo First, sign into the App Store with your Apple ID and Password.
echo Make an Apple account if you need to.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'re signed into your account.
	read finished
	done
echo

echo Now download the Xcode App.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when Xcode starts downloading.
	read finished
	done
echo

echo The download might take a while, so for now, let us move on.
echo Trying to make /etc/default...
mkdir /etc/default
echo Trying to make /etc/default/ec2-userdata...
echo ENV=dev > /etc/default/ec2-userdata
cd
echo Making Projects folder...
mkdir Projects
echo

echo Installing homebrew...
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo

echo While we wait for Xcode, set up your printer.
echo Click the Fullscreen logo at the bottom of the screen.
echo Your closest printer is probably Slayer.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when your printer is set up.
	read finished
	done
echo

echo Set up a Slack account if you haven\'t already.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have your Slack account.
	read finished
	done
echo

echo Now contact IT with the Slack FSIT channel or email helpdesk@fullscreen.com.
echo Ask IT to send an invitation to Lastpass Enterprise and license for JetBrains.
echo \(Specifically, you need data grip and pycharm from JetBrains.\)
finished="no"
until [ $finished = Y ]; do
	echo Type Y when IT has responded with your licenses.
	read finished
	done
echo

echo Install the Lastpass App \(and browser plugin\)
echo and JetBrain App \(and install datagrip and pycharm\).
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have those apps.
	read finished
	done
echo

echo To set up an SSH key-pair, enter your Fullscreen email:
read email
echo
echo When asked for a file location, just hit Enter.
echo When asked for passphrase, just hit Enter.
echo
ssh-keygen -t rsa -b 4096 -C $email
echo

echo Find your key with the following input:
echo cat /Users/\(yourfirsnametinitalyourlastname\)/.ssh/id_rsa.pub
echo \(Mine was first initial, last name, then LA, so check your Users folder.\)
finished="no"
until [ $finished = Y ]; do
	echo Input \'cat /Users/\(yourfirsnametinitalyourlastname\)/.ssh/id_rsa.pub\':
	read command
	echo
	$command
	echo
	echo Type Y when you have copy-pasted your key. Type anything else to try again.
	read finished
	done
echo

echo Make a GitHub account for your Fullscreen email address.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have logged into that account.
	read finished
	done
echo

echo What is your new GitHub username?
read username
echo
echo Installing git...
brew install git
git config --global user.name $username
git config --global user.email $email
echo

echo On GitHub, navigate to Settings \> SSH and GPG keys. Click \"New SSH key.\"
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have added the SSH key we generated.
	read finished
	done
echo

echo Download the Authy App on your phone. \(Use wifi FS Guest. Ask IT for password.\)
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have the Authy App.
	read finished
	done
echo

echo On GitHub, navigate to Settings \> Security \> Enable Two-Factor Authentication.
echo Use Authy to scan the QR code and generate six-digit codes.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have used Authy to enable GitHub\'s Two-Factor Authentication.
	read finished
	done
echo

echo Installing packages. You may need to enter your password...
brew install git-flow
brew install git-lfs
brew install postgresql
sudo git lfs install --system
echo

echo 'Ask Alex for devops on GitHub to let you install aws-rotate-key and aws-ssh.'
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you can install those packages.
	read finished
	done
brew install aws-rotate-key
brew install aws-ssh
echo
echo To set up Python, Xcode should be installed.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when Xcode has finished installing.
	read finished
	done
echo

echo Installing Python...
git clone git://github.com/yyuu/pyenv.git .pyenv
git clone https://github.com/yyuu/pyenv-virtualenv.git .pyenv/plugins/pyenv-virtualenv
pyenv install 2.7.6
pyenv install 2.7.15
pyenv install 3.4.4
pyenv install 3.7.0
pyenv global 3.7.0
echo

echo Installing awscli...
brew install awscli
echo

echo I\'m creating/opening your bash file. Add these lines to the END:
touch .bash_profile
open ~/.bash_profile
echo
echo 'eval "$(pyenv init -)"'
echo 'if command -v pyenv 1>/dev/null 2>&1'
echo then
echo export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV=\"true\"
echo export WORKON_HOME=\$HOME/.virtualenvs
echo export PROJECT_HOME=\$HOME/Projects
echo 'eval "$(pyenv init -)"'
echo pyenv virtualenvwrapper
echo fi
echo

finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'re done with the bash file.
	read finished
	done
echo

echo Download Sourcetree from https://www.sourcetreeapp.com/
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'ve downloaded Sourcetree.
	read finished
	done
echo
echo Open Sourcetree and click the gear in the top right. Select Accounts.
echo Create an account connected to your GitHub username and fullscreen email.
echo Use HTTPS, not SSH, and connect account.
echo Click the Commit tab and select \'push to remove,\' \'fixed-width font,\' and \'display column guide at character 72.\'
echo Finally, click the General tab and select \'Projects\' as your project folder.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'ve configured Sourcetree.
	read finished
	done
echo

echo Close Sourcetree\'s options window and look at Sourcetree proper.
echo You should now have a \'Projects\' entity. Double-click it.
echo Right-click the toolbar along the top and select \'Customize Toolbar.\'
echo Drag the \'git-flow\' icon to the toolbar.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'ve added git-flow to Sourcetree.
	read finished
	done
echo

echo Let us install Luigi. Ask Alex to let you clone from the Fullscreen GitHub.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you can clone Luigi from the Fullscreen GitHub.
	read finished
	done
echo

echo Cloning Luigi...
git clone https://github.com/Fullscreen/luigi ~/Projects/luigi
echo

echo Install this version of Python if not installed already:
CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install 2.7.15
echo
echo Destroying old tank if it exists...
rmvirtualenv tank
echo
pyenv shell 2.7.15
mkvirtualenv -a ~/Projects/luigi/codedeploy/tank -r ~/Projects/luigi/codedeploy/tank/requirements.txt tank
