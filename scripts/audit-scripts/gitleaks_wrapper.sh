#!/bin/bash

# accept gitleaks report as an argument
if [ -z "$1" ]
then
	echo "[*] Usage    : $0 <gitleaks json report>"
exit 0
fi

# initialize variables
WHITELIST_FILE="whitelist.txt"
suppressed_issues=()
ISSUE_NUM=0
gitleaks_report_json_path="$1"

# loop through every issue in the report
while read -r; do
    # extract the secret from the current issue
    current_finding=$(jq -r ".[$ISSUE_NUM] | .Secret" "$gitleaks_report_json_path")
    #echo "current_finding: $current_finding"
    #echo $ISSUE_NUM

    # check each item in our whitelist of false postive secrets to see if any match the current finding
    while IFS= read -r not_secret
    do
        # if current finding is in the whitelist, then we don't consider it secret and can add it to a list of suppressed findings
        if [ "$current_finding" == "$not_secret" ]; then
            suppressed_issues+=( "$ISSUE_NUM" )
        fi
    done < <(cat $WHITELIST_FILE)

    # now that we know the suppressed issues array is updated, we check if our current issue is in there
    if [[ ${suppressed_issues[*]} =~ $ISSUE_NUM ]]; then
        # if it is we just skip it and do nothing
        true
    else
        # if it's not then that means this finding isn't in the whitelist and we should print all the details for it
        jq ".[$ISSUE_NUM]" "$gitleaks_report_json_path"
    fi

    # Increment the issue number so we can keep track of where we are in the
    # gitleaks report json array. Also, || true bits ignore error status code when
    # incrementing from 0 to 1.
    (( ISSUE_NUM++ )) || true

done < <(jq -c '.[]' "$gitleaks_report_json_path")

echo "Suppressed issues: ${suppressed_issues[*]}"

#rm -v "gitleaks_report.json"
