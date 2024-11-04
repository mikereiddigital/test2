# This takes the output of the previous step and generates a json file containing a markdown-formatted list ready to be sent to slack
# If no file is found from the previous output, it will exit.

# Check if recent_failures.json exists, is not empty, and contains valid JSON. Else exit.
if jq empty recent_failures.json > /dev/null 2>&1; then
    # This generates a Slack message in JSON format using jq
    slack_message=$(jq -n --arg reporting_period "$REPORTING_PERIOD" --slurpfile failures recent_failures.json '
    {
        "blocks": (
        [
            {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":no_entry: *Recent Failed GitHub Actions*"
            }
            },
            {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "The following workflows have failed in the past \($reporting_period) days without subsequent success:"
            }
            },
            {
            "type": "divider"
            }
        ] + ($failures[0] | map(
            {
            "type": "section",
            "fields": [
                {
                "type": "mrkdwn",
                "text": "*Workflow:*\n<\(.url)|\(.name)>"
                },
                {
                "type": "mrkdwn",
                "text": "*Created At:*\n\(.created_at)"
                }
            ]
            },
            {
            "type": "divider"
            }
        ))
        )
    }'
    )
else
    echo "No report json file presented"
fi

echo "$slack_message"