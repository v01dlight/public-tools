#!/bin/bash
# this script is a wrapper around https://github.com/gitleaks/gitleaks which enables results to be suppressed via a whitelist of false positives
# it's intended for situations where the normal suppression by Fingerprint doesn't work because of dynamic filenames or something, such as when scanning a web bundle in a CI/CD pipeline

# accept gitleaks report as an argument
if [ -z "$1" ]
then
	echo "[*] Usage    : $0 <gitleaks json report> <output format (table or list)>"
exit 0
fi

# initialize variables
WHITELIST_FILE="gitleaks-web-bundle-whitelist.txt"
suppressed_issues=()
ISSUE_NUM=0
gitleaks_report_json_path="$1"
output_format="$2"
FILTERED_ISSUES_FILE="gitleaks_filtered_issues.json"

# loop through every issue in the report
while read -r; do
    # extract the secret from the current issue
    current_finding=$(jq -r ".[$ISSUE_NUM] | .Secret" "$gitleaks_report_json_path")
    hash=$(echo "$current_finding" | shasum | cut -f 1 -d " ")
    #echo "current_finding: $current_finding"
    #echo $ISSUE_NUM

    # check each item in our whitelist of false postive secrets to see if any match the current finding
    while IFS= read -r suppressed_finding
    do
        # if a hash of the current finding is in the whitelist, add it to a list of suppressed findings
        if [ "$hash" = "$suppressed_finding" ]; then
            suppressed_issues+=( "$ISSUE_NUM" )
        fi
    done < <(cat $WHITELIST_FILE)

    # now that we know the suppressed issues array is updated, we check if our current issue is in there
    if [[ ${suppressed_issues[*]} =~ $ISSUE_NUM ]]; then
        # if it is we just skip it and do nothing
        true
    else
        if [ "$output_format" = "table" ]; then
            # if it's not then that means this finding isn't in the whitelist and we should print all the details for it
            jq ".[$ISSUE_NUM]" "$gitleaks_report_json_path" >> $FILTERED_ISSUES_FILE
            echo ',' >> $FILTERED_ISSUES_FILE
        else
            DESCRIPTION=$(jq -r ".[$ISSUE_NUM] | .Description" "$gitleaks_report_json_path")
            LINE=$(jq -r ".[$ISSUE_NUM] | .StartLine" "$gitleaks_report_json_path")
            FILE=$(jq -r ".[$ISSUE_NUM] | .File" "$gitleaks_report_json_path")

            echo "Description: $DESCRIPTION"
            echo "Line: $LINE"
            echo "File: $FILE"
            echo "Secret: $current_finding"
            echo "To suppress, add '$hash' to $WHITELIST_FILE"
            echo ""
        fi
    fi

    # Increment the issue number so we can keep track of where we are in the
    # gitleaks report json array. Also, || true bits ignore error status code when
    # incrementing from 0 to 1.
    (( ISSUE_NUM++ )) || true

done < <(jq -c '.[]' "$gitleaks_report_json_path")

if [ "$output_format" = "table" ]; then
    # fix some formatting on the filtered issues file so it's a proper json array
    sed -i '' '$ s/.$//' $FILTERED_ISSUES_FILE
    echo '[' | cat - $FILTERED_ISSUES_FILE > temp && mv temp $FILTERED_ISSUES_FILE
    echo ']' >> $FILTERED_ISSUES_FILE

    # output the filteres issues file as a nicely formatted table
    cat $FILTERED_ISSUES_FILE | jq -r '(["RULE","SECRET","FILE","LINE"] | (.,map(length*"-"))), (.[] | [.RuleID, .Secret, .File, .StartLine]) | @tsv' | column -t
fi


# output a report on how many issues were suppressed by the whitelist
printf "\n+++++++++\n"
echo "${#suppressed_issues[*]} issues were suppressed by the whitelist: $WHITELIST_FILE"

if [ "$output_format" = "table" ]; then
    rm $FILTERED_ISSUES_FILE
fi