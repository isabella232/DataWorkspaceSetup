#!/bin/bash
echo
echo Install this version of Python if not installed already:
CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install 2.7.15
echo
echo Destroy old tank
rmvirtualenv tank
echo
pyenv shell 2.7.15
mkvirtualenv -a ~/Projects/luigi/codedeploy/tank -r ~/Projects/luigi/codedeploy/tank/requirements.txt tank
