terraform {
  required_providers {
    aws ={
        source = "hashicorp.aws"
        version = "~>4.0"
    }
  }
  backend "s3" {
    key = "aws/ec2-deploy/terraform.tfstate"
  }
}


provider "aws" {
  region = var.region
}

resource "aws_security_group" "group1" {
    egress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = ""
      from_port = 0
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "-1"
      self = false
      to_port = 0
    },
    ]
    ingress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = ""
      from_port = 22
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "tcp"
      self = false
      to_port = 22
    },
    {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = ""
      from_port = 80
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "tcp"
      self = false
      to_port = 80
    }
    ]
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = "ec2-ecr-auth"
}

resource "aws_instance" "server" {
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.micro"
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [ aws_security_group.group1.id ]
    iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ubuntu"
      private_key = aws_key_pair.deployer.public_key
      timeout = "4m"
    }

    tags = {
      name = "DeployVM"
    }
}



resource "aws_key_pair" "deployer" {
  key_name = var.key_name
  public_key = var.public_key

}
