terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
#Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}

#Create EC2 Instance
resource "aws_instance" "jenkins-ec2" {
  ami                       = "ami-0a6b545f62129c495"
  instance_type             = "t2.micro"
  key_name                  = "Jenkins-server"
  vpc_security_group_ids    = [aws_security_group.jenkins-sg.id]
  user_data                 = file("install_jenkins.sh")

  tags = {
    Name = "Myweek20project"
  }
}


#Create security group 
resource "aws_security_group" "myjenkins_sg" {
  name        = "jenkins_sg20"
  description = "Allow inbound ports 22, 8080"

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    description = "Allow SSH Trafic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    description = "Allow 8080 Traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#Create S3 bucket for Jenksin Artifacts
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = "jenkins-s3-bucket-week20terraform"

  tags = {
    Name = "Jenkins-Server"
  }
}

#make sure is prive and not open to public and create Access control List
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}