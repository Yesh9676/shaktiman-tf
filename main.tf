provider "aws" {
  region                   = "ap-south-1"
  shared_credentials_files = ["/Users/YESWANTH/.aws/credentials"]
}

resource "aws_security_group" "sg-1" {
  name        = "shaktiman-sg"
  description = "Allow Inbound Traffic"

  ingress {
    description = "SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "shaktiman_web_access"
    from_port   = "9090"
    to_port     = "9090"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Shaktiman_Web_Access"
  }
}

resource "aws_key_pair" "myec2-key" {
  key_name   = "shaktiman-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtcL5cUaI410XLrTwpnEBJUCEvI0ZIIeqfhoIoMpzz791Kkc7nioaFGInQfWLQtxCR2VP8/piSIJQ1wSTOGky3JbErOrcHNMHNtQdUVYVxSHYWNnmHsD55mXIo8qkF2ItW4UYa1St5167v3zVE1UKh7CP91/x45VwcvTXdSBWv85PL3utLJYbBjnIcsZ5CSio6bCi0VInQon/TdxHFZzQ6qVlodV1orwojvTy9m9RbZ+amsYxqa7fzNGD6tKzUk+h3ZzuqxDh+UY4dtpx8vMkWAmZJBQlcSSHnxvM5VvKFU/fQqoLbxvCE3vf0nA5vZWGyGfhcJOxmirmY+GFgMP77+B4BYQuAjSyNBKwE7KGVyJ9gmnS3Q0arWU2lT5JDCrg4vjwUis0O78zPt4fNMccyWScYosuSPVvs7mVmIxCzTfM3/RqxNC3KTwMEQXh7HN3VYKZCrIN7C5xDDrRThyn7jP6yNgZ0X6OYXcjdmg8oOuER2J0NjDjAqULNsQCZMfU= YESWANTH@Yaswanth"
}

resource "aws_instance" "myec2" {
  ami                    = "ami-0287a05f0ef0e9d9a"
  instance_type          = "t2.micro"
  key_name               = "shaktiman-key"
  vpc_security_group_ids = [aws_security_group.sg-1.id]
  user_data              = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo curl -fsSL https://get.docker.com -o docker.sh
                sudo sh docker.sh
                sudo docker pull yaswa2706/shaktiman:latest
                sudo docker run --name shaktiman -d -p 9090:8080 yaswa2706/shaktiman:latest
              EOF

  tags = {
    Name = "Docker-Machine"
  }
}


resource "aws_cloudwatch_metric_alarm" "shaktiman-cpu-alarm" {
  alarm_name          = "shaktiman-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  actions_enabled     = false 
  alarm_description   = "Alarm when CPU exceeds 90% for 2 consecutive periods"
}

resource "aws_cloudwatch_metric_alarm" "shaktiman-memory-alarm" {
  alarm_name          = "shaktiman-memory-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  actions_enabled     = false 
  alarm_description   = "Alarm when Memory exceeds 90% for 2 consecutive periods"
}
