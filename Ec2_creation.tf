provider "aws" {
    region = "us-west-2"  
}

resource "aws_instance" "foo" {
  ami           = "ami-002829755fa238bfa" # us-east-1
  instance_type = "t2.micro"
  key_name      = "autojen_inst_in_ec2"
  tags = {
      Name = "ec2-TFjenkins-Instance"
  }
}
