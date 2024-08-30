terraform {
  backend "s3" {
    bucket         = "gov-state-file-bucket"
    key            = "golbal/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "s3-gov-table"
  }
}
