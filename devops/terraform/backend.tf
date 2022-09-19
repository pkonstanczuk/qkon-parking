terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15"
    }
  }
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/38781476/terraform/state/default"
    lock_address   = "https://gitlab.com/api/v4/projects/38781476/terraform/state/default/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/38781476/terraform/state/default/lock"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}