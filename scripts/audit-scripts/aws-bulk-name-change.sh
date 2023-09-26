#!/bin/bash
# this script is for changing aws usernames in bulk. It requires the AWS CLI to already be set up and authenticated,
# as well as for you to have the relevant AWS permissions to change someone's name. As currently written it's expecting a list of names with no email extension, 
# and then it changes the email extension in the username as seen below. Modify as needed.

if [ -z "$1" ]
then
	echo "[*] Usage    : $0 <input list>"
exit 0
fi

for name in $(cat $1)
do
	echo "[+] Changing $name";
	aws iam update-user --user-name "$name@old" --new-user-name "$name@new"
done
