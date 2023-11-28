resource "aws_dynamodb_table" "tf_backend_state_lock_table" {
  count        = var.dynamodb_lock_table_enabled ? 1 : 0
  name         = var.dynamodb_lock_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Description        = "Terraform state locking table for account ${data.aws_caller_identity.current.account_id}."
    ManagedByTerraform = "true"
    TerraformModule    = "terraform-aws-backend"
  }

  lifecycle {
    prevent_destroy = true
  }
}