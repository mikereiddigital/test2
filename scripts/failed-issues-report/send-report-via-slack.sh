# This bash script sends the contents of a json file to the modernisation platform slack channel.
# It is dependent on the json file being generated in the script get-failed-issues. Otherwise no report is sent.

slack_url = $SLACK_WEBHOOK_URL
slack_headers = {
    "Authorization": f"Bearer {SLACK_TOKEN}",
    "Content-Type": "application/json"
}
slack_data = {
    "channel": SLACK_CHANNEL_ID,
    "text": message
}

        slack_response = requests.post(slack_url, headers=slack_headers, json=slack_data)

        if slack_response.status_code == 200 and slack_response.json().get("ok"):
            print("Failed runs message sent to Slack successfully.")
        else:
            print(f"Failed to send message to Slack: {slack_response.text}")

    else:
        print("No failed GitHub Actions in the past 24 hours.")

else:
    print(f"Failed to fetch GitHub actions data: {response.status_code} - {response.text}")