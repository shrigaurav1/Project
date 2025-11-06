terraform {
 backend "s3" {
 bucket = "ecsmodule"
 key = "terraform.tfstate"
 region = "us-west-2"
 dynamodb_table = "moduleog"
 }
}