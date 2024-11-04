# This bash script sends the contents of a json file to the modernisation platform slack channel.
# It is dependent on the json file being generated in the script get-failed-issues. Otherwise no report is sent.

#!/bin/bash

# Ensure the script is called with the webhook URL and payload file
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 SLACK_WEBHOOK_URL PAYLOAD_FILE"
  exit 1
fi

# Assign variables for webhook URL and payload file
SLACK_WEBHOOK_URL="$1"
PAYLOAD_FILE="$2"

# Check if the payload file exists and is valid JSON
if ! jq empty "$PAYLOAD_FILE" > /dev/null 2>&1; then
  echo "Error: $PAYLOAD_FILE is not valid JSON or does not exist."
  exit 1
fi

# Read the JSON payload from the file
PAYLOAD=$(cat "$PAYLOAD_FILE")

# Send the payload to Slack
response=$(curl -s -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$SLACK_WEBHOOK_URL")

# Check for a successful response
if [[ "$response" == "ok" ]]; then
  echo "Message sent to Slack successfully."
else
  echo "Failed to send message to Slack. Response: $response"
  exit 1
fi
