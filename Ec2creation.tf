provider "aws" {
    region = "us-west-2"  
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}

# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  # allow access on port 8080
  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "jenkins server security group"
  }
}

## launch the ec2 instance
resource "aws_instance" "foo" {
  ami           = "ami-002829755fa238bfa" # us-east-1
  instance_type = "t2.micro"
  vpc_security_group_ids = ["aws_security_group.ec2_security_group.id"]
  key_name      = "autojen_inst_in_ec2"
  tags = {
      Name = "ec2-TFjenkins-Instance"
  }
}

# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/ec2-user/PEM/autojen_inst_in_ec2.pem")
    host        = aws_instance.foo.public_ip
  }

  # copy the install_jenkins.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "/home/ec2-user/Scripts/install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
  }

  # set permissions and run the install_jenkins.sh file
  provisioner "remote-exec" {
    inline = [
        "sudo chmod +x /tmp/install_jenkins.sh",
        "sh /tmp/install_jenkins.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.foo]
}


# print the url of the jenkins server
output "website_url" {
  value     = join ("", ["http://", aws_instance.foo.public_dns, ":", "8080"])
}
