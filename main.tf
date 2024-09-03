# Specify the provider
provider "aws" {
  region = "ap-south-1"  # Change the region if needed
}

# Define a security group to allow SSH, port 5000 and port 3000 access
resource "aws_security_group" "allow_ssh_5000_3000" {
  name        = "allow_ssh_5000_3000"
  description = "Allow SSH and port 5000 inbound traffic"

  # Ingress rule to allow SSH (port 22) from any IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule to allow port 5000 from any IP address
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule to allow port 3000 from any IP address
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0818919f15d5129fe"  # Amazon Linux 2 AMI ID (change if needed)
  instance_type = "t2.micro"

  # Attach the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_5000_3000.id]

  # Use user data to install Docker, Docker Compose, Git, clone a repository, and run Docker Compose
  user_data = <<-EOF
              #!/bin/bash
              # Update the package index
              yum update -y

              # Install Docker and Git
              yum install -y docker git

              # Start Docker service and add ec2-user to the docker group
              service docker start
              usermod -aG docker ec2-user

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              
              chmod +x /usr/local/bin/docker-compose

              # Clone the Git repository
              cd /home/ec2-user/
              git clone https://github.com/sreekuttan2255/My-Voting-Application.git 

              # Change directory to the cloned repository
              cd /home/ec2-user/My-Voting-Application

              # Run Docker Compose
              docker-compose up -d
              EOF

  tags = {
    Name = "MyEC2Instance"
  }
}

# Output the instance public IP
output "instance_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}
