workflow "Publish to SNS topic" {
  on = "push"
  resolves = ["Publish"]
}

action "Topic" {
  uses = "actions/aws/cli@master"
  args = "sns create-topic --name my-topic"
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}

action "Publish" {
  needs = ["Topic"]
  uses = "actions/aws/cli@master"
  args = "sns publish --topic-arn `jq .TopicArn /github/home/Topic.json --raw-output` --subject \"[$GITHUB_REPOSITORY] Code was pushed to $GITHUB_REF\" --message file://$GITHUB_EVENT_PATH"
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}
