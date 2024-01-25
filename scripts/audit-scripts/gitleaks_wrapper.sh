#!/bin/bash
# this script is a wrapper around https://github.com/gitleaks/gitleaks which enables results to be suppressed via a whitelist of false positives

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
FILTERED_ISSUES_FILE="gitleaks_filtered_issues.json"

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
        if [ "$current_finding" = "$not_secret" ]; then
            suppressed_issues+=( "$ISSUE_NUM" )
        fi
    done < <(cat $WHITELIST_FILE)

    # now that we know the suppressed issues array is updated, we check if our current issue is in there
    if [[ ${suppressed_issues[*]} =~ $ISSUE_NUM ]]; then
        # if it is we just skip it and do nothing
        true
    else
        # if it's not then that means this finding isn't in the whitelist and we should print all the details for it
        jq ".[$ISSUE_NUM]" "$gitleaks_report_json_path" >> $FILTERED_ISSUES_FILE
        echo ',' >> $FILTERED_ISSUES_FILE
    fi

    # Increment the issue number so we can keep track of where we are in the
    # gitleaks report json array. Also, || true bits ignore error status code when
    # incrementing from 0 to 1.
    (( ISSUE_NUM++ )) || true

done < <(jq -c '.[]' "$gitleaks_report_json_path")

# fix some formatting on the filtered issues file so it's a proper json array
sed -i '' '$ s/.$//' $FILTERED_ISSUES_FILE
echo '[' | cat - $FILTERED_ISSUES_FILE > temp && mv temp $FILTERED_ISSUES_FILE
echo ']' >> $FILTERED_ISSUES_FILE

# output the filteres issues file as a nicely formatted table
cat $FILTERED_ISSUES_FILE | jq -r '(["RULE","SECRET","FILE","LINE"] | (.,map(length*"-"))), (.[] | [.RuleID, .Secret, .File, .StartLine]) | @tsv' | column -t

# output a report on how many issues were suppressed by the whitelist
printf "\n+++++++++\n"
echo "${#suppressed_issues[*]} issues were suppressed by the whitelist: $WHITELIST_FILE"

rm $FILTERED_ISSUES_FILE