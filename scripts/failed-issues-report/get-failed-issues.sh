# This bash script get the URL for each failed workflow action in Modernisation Platform repo as follows:
# - Gets all completed workflows that completed in the past 24 hours
# - Of those, finds the latest failed action only. Ignores any previously failed actions,
# - Ignores failed actions that have had a subsequent successful action,

# The GitHub API expects dates in ISO 8601 format for filtering parameters like created or updated.
# We want the date & time as at 24 hours ago.
PERIOD=$(date -u --date="$REPORTING_PERIOD hours ago" +"%Y-%m-%dT%H:%M:%SZ")
echo "Getting all workflows that completed since $PERIOD"

# The updated_at field provides the finished date so we check against that.
# The created field is for all actions that have completed including those that have failed.
GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPO/actions/runs?updated_at=>=$PERIOD&status=completed"

response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL")

# This section iterates through each of the workflows returned above, sorts in asc date order and looks for those that have the conclusion status of failure.
recent_failures=$(echo "$response" | jq -r '
  # Group by workflow name
  .workflow_runs | group_by(.name) | 
  map(
    # Sort each group by created_at, descending (newest first)
    sort_by(.created_at) | reverse |
    # Find the latest failure, only if no subsequent success exists
    if (map(select(.conclusion == "success")) | length) == 0 
      or (first(.[] | select(.conclusion == "failure")) 
      as $failure | .[0: (index($failure))] | 
      map(select(.conclusion == "success")) | length) == 0 
    then 
      # Output the latest failure in the group if no subsequent success
      first(.[] | select(.conclusion == "failure")) | 
      {name: .name, url: .html_url, status: .conclusion, created_at: .created_at}
    else empty end
  ) | 
  .[] | select(.status == "failure")
')

# This checks the contents of $recent_failures and if not empty it saves the variable to a file for use in the next step.
formatted_date=$(date -d "$original_date" +"%d-%m-%Y %H:%M:%S")
if [[ -n "$recent_failures" ]]; then
  echo "Most recent failed GitHub Actions without subsequent success that finished since $formatted_date :"
  echo "$recent_failures" | jq -r '. | "\(.name): \(.created_at) - \(.url)"'
  echo "$recent_failures" > recent_failures.json
else
  echo "No workflow failures without subsequent successful completion that finished since $formatted_date ."
fi
