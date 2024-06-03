terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


  backend "s3" {
    bucket = "devops-first-s3-bucket-1" # Replace with your bucket name
    key    = "ec2-deploy/terraform.tfstate"
    region = "us-east-1"  # Replace with the AWS region of your bucket
  }
}


provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


resource "aws_security_group" "group1" {
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    self             = false
    to_port          = 0
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    self             = false
    to_port          = 22
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    self             = false
    to_port          = 80
  }
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile-1"
  role = "ec2-ecr-auth"
}

resource "aws_instance" "server" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.group1.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-profile.name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.aws_key_pair.deployer.public_key)  # Assuming the private key is stored in a file
    timeout     = "4m"
  }

  tags = {
    Name = "DeployVM"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}
