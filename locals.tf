# Get AWS account ID
locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Get short name for regions
locals {
  region_short_names = {
    us-east-1    = "use1"
    us-west-2    = "usw2"
    eu-central-1 = "euc1"
    eu-west-1    = "euw1"
    eu-south-1   = "eus1"
    # Add more regions as needed
  }
}
