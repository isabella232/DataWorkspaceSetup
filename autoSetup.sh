#!/bin/bash
echo
echo ----------------------------------------------------------------
echo This program helps prepare an OSX computer for data engineers.
echo
echo -e 'For more detail, see https://fullscreenmedia.atlassian.net/wiki'
echo -e '\t /spaces/DE/pages/42735377/OSX+New+Computer+Setup'
echo ----------------------------------------------------------------
echo

echo First, sign into the App Store with your Apple ID and Password.
echo Make an Apple account if you need to, using your Fullscreen email address.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'re signed into your account.
	read finished
	done
echo

echo Now download the Xcode app from the App Store.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when Xcode starts downloading.
	read finished
	done
echo

echo The download might take a while, so for now, let\'s move on.
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
echo Tapping the Fullscreen brew...
brew tap fullscreen/tap
echo

echo While we wait for Xcode, set up your printer.
echo Click the Fullscreen logo at the bottom of the screen.
echo Your closest printer is probably \'Slayer.\'
finished="no"
until [ $finished = Y ]; do
	echo Type Y when your printer is set up.
	read finished
	done
echo

echo If you haven\'t already, set up a Slack account for your Fullscreen email.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have your Slack account.
	read finished
	done
echo

echo Now contact IT by emailing helpdesk@fullscreen.com,
echo -e '\t or open Slack and use the #fsit channel.'
echo Ask IT to send an invitation to Lastpass Enterprise and license for JetBrains.
echo \(Specifically, you need data grip and pycharm from JetBrains.\)
finished="no"
until [ $finished = Y ]; do
	echo Type Y when IT has responded with your licenses.
	read finished
	done
echo

echo Install the Lastpass app \(and browser plugin\)
echo and JetBrain app \(and install datagrip and pycharm\).
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have those apps.
	read finished
	done
echo

echo To set up an SSH key-pair, enter your Fullscreen email:
read email
echo
echo When asked for a file location, just hit Enter/Return.
echo When asked for passphrase, just hit Enter/Return.
echo
ssh-keygen -t rsa -b 4096 -C $email
echo

echo Copy this key to your clipboard:
echo
cat ~/.ssh/id_rsa.pub
finished="no"
until [ $finished = Y ]; do
	echo
	echo Type Y when you have copied your key.
	read finished
	done
echo

echo Make a GitHub account for your Fullscreen email address.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have logged into that GitHub account.
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

echo Download the Authy app on your phone. \(Use wifi FS Guest. Ask IT for password.\)
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you have the Authy app.
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

#echo 'Ask Alex for devops on GitHub to let you install aws-rotate-key and aws-ssh.'
#finished="no"
#until [ $finished = Y ]; do
#	echo Type Y when you can install those packages.
#	read finished
#	done
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

echo Installing command-line-tools...
xcode-select --install
echo

#echo Clean previous Python installs? Y/N
#read answer
#until [ $answer = "N" ]; do
#	if [ $answer = "Y" ]; then
#		python -m pip uninstall virtualenvwrapper
#		python -m pip uninstall virtualenv-clone
#		python -m pip uninstall virtualenv
#		brew uninstall python@2
#		brew uninstall awscli
#		brew uninstall --force python
#		rm -rf ~/.virtualenvs*
#		answer="N"
#	else
#		echo I\'m sorry, what was that?
#		read answer
#	fi
#done
#echo

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

echo I\'m creating/opening your bash profile. Add these lines to the end:
touch .bash_profile
open ~/.bash_profile
echo
echo -----------------------------------------------------------
echo -e 'eval "$(pyenv init -)"'
echo -e 'if command -v pyenv 1>/dev/null 2>&1'
echo -e 'then'
echo -e '\t export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"'
echo -e '\t export WORKON_HOME=$HOME/.virtualenvs'
echo -e '\t export PROJECT_HOME=$HOME/Projects'
echo -e '\t eval "$(pyenv init -)"'
echo -e '\t pyenv virtualenvwrapper'
echo -e 'fi'
echo -----------------------------------------------------------
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
echo Create an account connected to your GitHub username and Fullscreen email.
echo Use HTTPS, not SSH, and connect account.
echo Click the Commit tab and select \'push to remove,\' \'fixed-width font,\'
echo -e "\t and 'display column guide at character 72.'"
echo Finally, click the General tab and select \'Projects\' as your project folder.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'ve configured Sourcetree.
	read finished
	done
echo

echo Close Sourcetree\'s Accounts window and look at Sourcetree proper.
echo You should now have a \'Projects\' entity. Double-click it.
echo Right-click the toolbar along the top and select \'Customize Toolbar.\'
echo Drag the \'git-flow\' icon to the toolbar.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'ve added git-flow to Sourcetree.
	read finished
	done
echo

echo Now let\'s install Luigi. Ask Alex to add you to the Fullscreen GitHub.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you can clone Luigi from the Fullscreen GitHub.
	read finished
	done
echo

echo Cloning Luigi...
git clone https://github.com/Fullscreen/luigi ~/Projects/luigi
echo

echo Destroying old tank if it exists...
rmvirtualenv tank
pyenv shell 2.7.15
echo Making new tank...
echo 
mkvirtualenv -a ~/Projects/luigi/codedeploy/tank -r ~/Projects/luigi/codedeploy/tank/requirements.txt tank
echo
echo We should now be working in the Tank environment.
workon tank
pyenv local 2.7.15
sudo mkdir /data
sudo chown $(id -un):$(id -gn) /data
sudo mkdir /etc/luigi
sudo chown $(id -un):$(id -gn) /etc/luigi
sudo mkdir /var/log/luigi
sudo chown $(id -un):$(id -gn) /var/log/luigi
sudo cp -a ../config/* /etc/luigi/
add2virtualenv ~/Projects/luigi/codedeploy/tank
echo Installing credstash...
pip install credstash
deactivate
echo Leaving Tank
echo

echo Contact devops to set up an Amazon Web-Service account. \(Scott Stout helped me.\)
echo This will require LastPass and the Authy app.
finished="no"
until [ $finished = Y ]; do
	echo Type Y when you\'re logged onto the AWS console.
	read finished
	done
echo
echo ----------------------------------
echo This OSX computer is fully set up.
echo ----------------------------------
echo
