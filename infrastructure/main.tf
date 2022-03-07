terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.4.0"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.1.0"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
}

provider "aws" {
    alias = "acm_provider"
    region = "us-east-1"
}


terraform {
    backend "s3" {
        bucket = "logancox-blog-terraform"
        region = "eu-west-1"
        key    = "state/main"
    }
}
