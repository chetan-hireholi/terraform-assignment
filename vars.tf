variable "ami" {
  type = map
  default = {
    "us-east-1" = "ami-111222333444"
    "us-west-1" = "ami-555666777888"
  }
}

variable "instance_count" {
  default = "2"
}

variable "instance_type" {
  default = "t2.large"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "instance_tags" {
  type = list
  default = [" prod-web-server-1", " prod-web-server-2"]
}