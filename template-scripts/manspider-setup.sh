#!/bin/bash

function venv-setup {
	apt update &&
	apt install virtualenv -y
}

venv-setup

git clone https://github.com/blacklanternsecurity/MANSPIDER.git /opt/manspider
cd /opt/manspider
virtualenv --python=python3 /opt/manspider
source /opt/manspider/bin/activate
pip3 install -r requirements.txt
pip3 install .
