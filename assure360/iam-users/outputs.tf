# Sensitive output with each user's Access Key ID and Secret
output "developer_access_keys" {
  description = "Access keys for the four developers (distribute securely)."
  value = {
    for k, v in aws_iam_access_key.dev_keys :
    aws_iam_user.dev[k].name => {
      access_key_id     = v.id
      secret_access_key = v.secret
    }
  }
  sensitive = true
}
