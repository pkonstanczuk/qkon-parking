terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15"
    }
  }
  backend "s3" {
    #    TODO change
    bucket         = "parq-terraform-state"
    key            = "qparking"
    region         = "eu-central-1"
    dynamodb_table = "parkq-terraform-state-lock-dynamo"
  }
}

provider "aws" {
  region = "eu-central-1"
}
