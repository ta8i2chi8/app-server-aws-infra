terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  # backend "local" {}
  backend "s3" {
    bucket = "mybucket-name"
    key    = "terraform-dev.tfstate"
    region = "ap-northeast-1"
  }

  required_version = "= 1.4.6"
}

provider "aws" {
  region = "ap-northeast-1"

  # ~/.aws/credentialsの[default]を利用
  profile = "default"
}

module "network" {
  source = "../../modules/network"
}

module "security" {
  source = "../../modules/security"
  my-ip  = var.my-ip
  vpc-id = module.network.vpc-id
}

module "hello-app-server" {
  source            = "../../modules/hello-app-server"
  key-path          = var.key-path
  ec2-config        = var.ec2-config
  vpc-id            = module.network.vpc-id
  subnet-east-id    = module.network.subnet-east-id
  subnet-west-id    = module.network.subnet-west-id
  sg-test-lb-id     = module.security.sg-test-lb-id
  sg-test-server-id = module.security.sg-test-server-id
}

output "alb-domain" {
  value = module.hello-app-server.alb-domain
}
output "ec2-east-ip" {
  value = module.hello-app-server.ec2-east-ip
}
output "ec2-west-ip" {
  value = module.hello-app-server.ec2-west-ip
}