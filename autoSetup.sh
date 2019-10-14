#!/bin/bash
echo
echo "----------------------------------------------------------------"
echo "This program helps prepare an OSX computer for data engineers."
echo
echo -e 'For more detail, see https://fullscreenmedia.atlassian.net/wiki'
echo -e '\t /spaces/DE/pages/42735377/OSX+New+Computer+Setup'
echo "----------------------------------------------------------------"
echo

function prompt() {
  local msg=$1
  echo "$msg (ctrl+c to cancel)"
  read _
}

function collect_input() {
  local prompt=$1
  local default=$2
  local __resultvar=$3
  local confirm=''
  until [[ "y" == "$(echo $confirm|tr '[:upper:]' '[:lower:]')" ]]; do
    echo -n "$prompt [$default]: "
    read tmp
    echo "Is this correct? \"${tmp:-$default}\" (Y/N)"
    read confirm
  done
  eval $__resultvar="'${tmp:-$default}'"
}

function banner() {
    local length=$1
    for i in $(seq $length); do
        echo -n '='
    done
    echo
}

function bannerize() {
    local text=$1
    local max_len=0
    local c_len=0
    while read line; do
        c_len=$(echo $line | wc -c)
        if [ $max_len -lt $c_len ]; then
            max_len=$c_len
        fi
    done <<< "$(echo $text)"
    banner $max_len
    echo $text
    banner $max_len
}

function announce_install() {
  local human_name=$1
  local command_name=$2
  local install_command=$3
  local cmd=$(which $command_name)
  if [[ "" == "$cmd" ]]; then
    echo "Installing $human_name"
    $install_command
  fi
}

# collect_input "something" "default" my_tmp
# echo $my_tmp
# bannerize "subsection"
# announce_install thing thing1 "echo 'works if this line does not start with \"echo\"'"
# 
# 
# exit

bannerize "Installing base utilities"



###################################
announce_install homebrew brew "ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\" ; brew tap fullscreen/tap"

prompt "Testing for xcode-select, you may need to interact with a window to resolve this. Enter to continue."
XCODESELECT=$(xcode-select --install)
if [[ "1" == "XCODESELECT" ]]; then
  echo "xcode-select already installed, that's cool"
fi

prompt "When xcode-select is installed, hit enter."

bannerize "Really low level dev tools"
announce_install curl curl "brew install curl"
announce_install git git "brew install git"
announce_install hub hub "brew install hub"
announce_install "git flow" git-flow "brew install git-flow"
announce_install "git lfs" git-lfs "brew install git-lfs"
# announce_install jq jq "brew install jq"

bannerize "Less low level dev tools"
announce_install aws-cli aws "pip install awscli --upgrade --user"
announce_install "aws rotate key" aws-rotate-key "brew install aws-rotate-key"
announce_install aws-ssh aws-ssh "brew install aws-ssh"
announce_install docker docker "brew install docker"
announce_install docker docker "brew install docker-compose"

bannerize "Higher level generic tools"
if [[ ! -d "/Applications/Slack.app" ]]; then
  brew cask install slack
fi

bannerize "Configuring rcfile"
SH=$(echo $SHELL | rev | cut -d'/' -f1 | rev)
RCFILE=~/.${SH}rc
collect_input "Input your rcfile path" $RCFILE rcfile

source $rcfile  # ensure all settings are loaded incase we are rerunning in same shell

pdir=${PROJECTS_DIR:-~/Projects}
collect_input "Input your preferred projects directory" $pdir projects_dir
if [[ ! -d $projects_dir ]]; then
  mkdir -p $projects_dir
fi
echo "PROJECTS_DIR = '$PROJECTS_DIR'"
echo "pdir = '$pdir'"
if [[ "$PROJECTS_DIR" != "$projects_dir" ]]; then
  rc_configured=$(grep "PROJECTS_DIR=" $rcfile)
  if [[ "" != "$rc_configured" ]]; then
    echo "Appending new projects dir, overwriting old projects dir $PROJECTS_DIR"
  fi
  echo "export PROJECTS_DIR=\"$projects_dir\"" >> $rcfile
fi

bannerize "Setting up ssh"
if [[ "" == "$FS_EMAIL" ]]; then
  collect_input "What is your FS email" "" FS_EMAIL
  echo "FS_EMAIL='$email'" >> $rcfile
fi

collect_input "Where to store this ssh key" ~/.ssh/id_rsa rsa_location
if [[ ! -f $rsa_location ]]; then
  ssh-keygen -t rsa -b 4096 -C $FS_EMAIL -f "$rsa_location" -N ""
fi
id_rsa_pub=$(cat "$rsa_location" | pbcopy)

GH_USER=$(git config --get user.name)
GH_EMAIL=$(git config --get user.email)
bannerize "GitHub configuration"
if [[ "" == "$GH_USER" ]]; then
  collect_input "What is your GitHub username?" '' gh_user
  users_search=$(curl "https://api.github.com/search/users?q=$gh_user")
  count=$(echo "$users_search" | jq -r .total_count)
  if [[ "1" != "$count" ]]; then
    echo "Looks like your github username is not unique... You're going to have to configure your git info yourself"
  else
    git config --global user.name $gh_user
    GH_USER=$gh_user
  fi
fi
if [[ "" == "$GH_EMAIL" ]]; then
  GH_EMAIL=$FS_EMAIL
  git config --global user.email $GH_EMAIL
fi




# todo:
#   - configure git
#   - configure github
#   - configure python tools
#   - install luigi
#   - configure luigi


bannerize "Configuring luigi-settings (you will be asked for sudo permissions)"
if [[ ! -d "/etc/default" ]]; then
  sudo mkdir /etc/default
fi
if [[ -f "/etc/default/ec2-userdata" ]]; then
  configured=$(grep '^ENV=' /etc/default/ec2-userdata)
  if [[ "" == "$configured" ]]; then
    echo "ENV=dev" | sudo tee -a /etc/default/ec2-userdata > /dev/null
  fi
else
  echo "Creating /etc/default/ec2-userdata..."
  echo "ENV=dev" | sudo tee -a /etc/default/ec2-userdata > /dev/null
fi

HOSTNAME=$(hostname|cut -d'.' -f1)
bannerize "Configuring github with ssh keys, you will be prompted for authentication information"
keys=$(hub api /users/${gh_user}/keys)


echo "Installing Python..."
announce_install pyenv pyenv "brew install pyenv"
announce_install pyenv-virtualenv pyenv-virualenv "brew install pyenv-virtualenv"
if [[ "" == "$(pyenv --versions | grep '2.7.15')" ]]; then
  echo "Installing python 2.7.15"
  pyenv install 2.7.15
fi
if [[ "" == "$(pyenv --versions | grep '3.7.0')" ]]; then
  echo "Installing python 3.7.0"
  pyenv install 3.7.0
  pyenv global 3.7.0
fi

if [[ "" == "$(grep 'eval "$(pyenv init -)"' $rcfile)" ]]; then
  echo "Adding pyenv configuration to $rcfile"
  echo 'eval "$(pyenv init -)"' >> $rcfile
  echo 'if command -v pyenv 1>/dev/null 2>&1' >> $rcfile
  echo 'then' >> $rcfile
  echo '  export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"' >> $rcfile
  echo '  export WORKON_HOME=$HOME/.virtualenvs' >> $rcfile
  echo '  export PROJECT_HOME=$HOME/Projects' >> $rcfile
  echo '  eval "$(pyenv init -)"' >> $rcfile
  echo '  pyenv virtualenvwrapper' >> $rcfile
  echo 'fi' >> $rcfile
  announce_install pyenv-virtualenvwrapper pyenv-virtualenvwrapper "brew install pyenv-virtualenvwrapper"
fi

if [[ "" == $(workon | grep 'tank') ]]; then
  pyenv shell 2.7.15
  echo "Making new tank..."
  mkvirtualenv -a $projects_dir/luigi/codedeploy/tank -r $projects_dir/luigi/codedeploy/tank/requirements.txt tank
  workon tank
  pyenv local 2.7.15
  sudo mkdir /data
  sudo chown $(id -un):$(id -gn) /data
  sudo mkdir /etc/luigi
  sudo chown $(id -un):$(id -gn) /etc/luigi
  sudo mkdir /var/log/luigi
  sudo chown $(id -un):$(id -gn) /var/log/luigi
  sudo cp -a ../config/* /etc/luigi/
  add2virtualenv $projects_dir/luigi/codedeploy/tank
  echo "Installing credstash..."
  pip install credstash
  deactivate
  echo "Leaving Tank"
fi
exit







echo "Now contact IT by emailing helpdesk@fullscreen.com,"
echo -e '\t or open Slack and use the #fsit channel.'
echo "Ask IT to send an invitation to Lastpass Enterprise and license for JetBrains."
echo "\(Specifically, you need data grip and pycharm from JetBrains.\)"
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when IT has responded with your licenses."
  read finished
  done
echo

echo "Install the Lastpass app \(and browser plugin\)"
echo "and JetBrain app \(and install datagrip and pycharm\)."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you have those apps."
  read finished
  done
echo


echo "On GitHub, navigate to Settings \> SSH and GPG keys. Click \"New SSH key.\""
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you have added the SSH key you copied."
  read finished
  done
echo

echo "Download the Authy app on your phone. \(Use wifi FS Guest. Ask IT for password.\)"
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you have the Authy app."
  read finished
  done
echo

echo "On GitHub, navigate to Settings \> Security \> Enable Two-Factor Authentication."
echo "Use Authy to scan the QR code and generate six-digit codes."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you have used Authy to enable GitHub\'s Two-Factor Authentication."
  read finished
  done
echo

echo "Installing packages. You may need to enter your password..."
brew install git-flow
brew install git-lfs
brew install postgresql
sudo git lfs install --system
echo

#echo "'Ask Alex for devops on GitHub to let you install aws-rotate-key and aws-ssh.'"
#finished="no"
#until [ $finished = Y ]; do
#  echo "Type Y when you can install those packages."
#  read finished
#  done
brew install aws-rotate-key
brew install aws-ssh
echo
echo "To set up Python, Xcode should be installed."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when Xcode has finished installing."
  read finished
  done
echo

echo "Installing command-line-tools..."
xcode-select --install
echo

#echo "Clean previous Python installs? Y/N"
#read answer
#until [ $answer = "N" ]; do
#  if [ $answer = "Y" ]; then
#    python -m pip uninstall virtualenvwrapper
#    python -m pip uninstall virtualenv-clone
#    python -m pip uninstall virtualenv
#    brew uninstall python@2
#    brew uninstall awscli
#    brew uninstall --force python
#    rm -rf ~/.virtualenvs*
#    answer="N"
#  else
#    echo "I\'m sorry, what was that?"
#    read answer
#  fi
#done
#echo


echo "I\'m creating/opening your bash profile. Add these lines to the end:"
touch .bash_profile
open ~/.bash_profile
echo
echo "------------------------------------------------------------"
echo -e 'eval "$(pyenv init -)"'
echo -e 'if command -v pyenv 1>/dev/null 2>&1'
echo -e 'then'
echo -e '\t export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"'
echo -e '\t export WORKON_HOME=$HOME/.virtualenvs'
echo -e '\t export PROJECT_HOME=$HOME/Projects'
echo -e '\t eval "$(pyenv init -)"'
echo -e '\t pyenv virtualenvwrapper'
echo -e 'fi'
echo "------------------------------------------------------------"
echo

finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you\'re done with the bash file."
  read finished
  done
echo

echo "Download Sourcetree from https://www.sourcetreeapp.com/"
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you\'ve downloaded Sourcetree."
  read finished
  done
echo
echo "Open Sourcetree and click the gear in the top right. Select Accounts."
echo "Create an account. Use HTTPS, not SSH, and connect it to your new GitHub."
echo "Click the Commit tab and select \'push to remove,\' \'fixed-width font,\'"
echo -e "\t and 'display column guide at character 72.'"
echo "Finally, click the General tab and select \'Projects\' as your project folder."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you\'ve configured Sourcetree."
  read finished
  done
echo

echo "Close Sourcetree\'s Settings window and look at Sourcetree proper."
echo "You should now have a \'Projects\' entity. Double-click it."
echo "Right-click the toolbar along the top and select \'Customize Toolbar.\'"
echo "Drag the \'git-flow\' icon to the toolbar."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you\'ve added git-flow to Sourcetree."
  read finished
  done
echo

echo "Now let\'s install Luigi. Ask Alex to add you to the Fullscreen GitHub."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you can clone Luigi from the Fullscreen GitHub."
  read finished
  done
echo

echo "Cloning Luigi..."
git clone https://github.com/Fullscreen/luigi ~/Projects/luigi
echo

echo "Destroying old tank if it exists..."
rmvirtualenv tank
pyenv shell 2.7.15
echo "Making new tank..."
echo
mkvirtualenv -a ~/Projects/luigi/codedeploy/tank -r ~/Projects/luigi/codedeploy/tank/requirements.txt tank
echo
echo "We should now be working in the Tank environment."
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
echo "Installing credstash..."
pip install credstash
deactivate
echo "Leaving Tank"
echo

echo "Contact devops to set up an Amazon Web-Service account. \(Scott Stout helped me.\)"
echo "This will require LastPass and the Authy app."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when you\'re logged onto the AWS console."
  read finished
done
echo
echo "Download and install Docker for Mac \(Stable version\)."
finished="no"
until [ $finished = Y ]; do
  echo "Type Y when Docker is installed."
  read finished
done
echo
echo "----------------------------------"
echo "This OSX computer is fully set up."
echo "----------------------------------"
echo
