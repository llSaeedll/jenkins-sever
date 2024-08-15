#Create EC2 Instance
resource "aws_instance" "jenkins-ec2" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids    = [aws_security_group.jenkins-sg.id]
  user_data                 = file("install_jenkins.sh")

  tags = {
    Name = "jenkins-server"
  }
}


#Create security group 
resource "aws_security_group" "jenkins-sg" {
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

resource "random_string" "bucket_suffix" {
  length = 6
  upper  = false
  special = false
}

#Create S3 bucket for Jenksin Artifacts
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = "jenkins-s3-bucket-${random_string.bucket_suffix.result}"

  tags = {
    Name = "Jenkins-Server"
  }
}

#make sure is prive and not open to public and create Access control List
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  acl    = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


output "jenkins_url" {
  value = "http://${aws_instance.jenkins-ec2.public_ip}:8080"
  description = "The URL to access Jenkins"
}