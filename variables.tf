variable "aws_region" {
  default = "ap-southeast-1"
  type    = string
}

variable "ami_id" {
  default = "ami-0a6b545f62129c495"
  type    = string
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

#หา key-name ในกรณีที่สร้าง Instance ครั้งแรก
#aws ec2 create-key-pair --key-name MyKeyName --query 'KeyMaterial' --output text > MyKeyPair.pem
variable "key_name" {
  default = "Jenkins-server"
  type    = string
}

variable "bucket" {
  default = "jenkins-s3-bucket-navideh123"
  type    = string
}

variable "acl" {
  default = "private"
  type    = string
}