provider "aws" {
  region ="us-west-2"
}

resource "aws_instance" "webserver" {
  ami ="ami-002829755fa238bfa"
  instance_type = "t2.medium"
  key_name = "autojen_inst_in_ec2"
  associate_public_ip_address = true

   provisioner "file" {
        source      = "install_jenkins.sh"
        destination = "/home/ec2-user/install_jenkins.sh"
       
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("autojen_inst_in_ec2.pem")}"
      host        = "${self.public_ip}"
    }
   }


  tags = {
    Name = "FileProvisionerinstance"
  }
}
