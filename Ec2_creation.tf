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

# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/ec2-user/PEM/autojen_inst_in_ec2.pem")
    host        = aws_instance.foo.public_ip
  }
  echo "----------------ssh done-------------"
  # copy the install_jenkins.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "/home/ec2-user/Scripts/install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
  }
  echo "----------copy install jenkins file done--------------"
  echo "--------install jenkins file execution in progress--------"
  # set permissions and run the install_jenkins.sh file
  provisioner "remote-exec" {
    inline = [
        "sudo chmod +x /tmp/install_jenkins.sh",
        "sh /tmp/install_jenkins.sh",
    ]
  }
  echo "---------install jenkins file execution completed-------"
  # wait for ec2 to be created
  depends_on = [aws_instance.foo]
}


# print the url of the jenkins server
output "website_url" {
  value     = join ("", ["http://", aws_instance.foo.public_dns, ":", "8080"])
}
