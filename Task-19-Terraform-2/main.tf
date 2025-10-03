# ===============================
# PROVIDERS
# ===============================
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"  # Mumbai
}

provider "aws" {
  alias  = "northvirginia"
  region = "us-east-1"   # North Virginia
}

# ===============================
# KEY PAIRS
# ===============================
resource "aws_key_pair" "mykey_mumbai" {
  provider   = aws.mumbai
  key_name   = "mykey"
  public_key = file("~/.ssh/mykey.pub")
}

resource "aws_key_pair" "mykey_northvirginia" {
  provider   = aws.northvirginia
  key_name   = "mykey"
  public_key = file("~/.ssh/mykey.pub")
}

# ===============================
# SECURITY GROUPS
# ===============================
resource "aws_security_group" "web_sg_mumbai" {
  provider = aws.mumbai
  name     = "web_sg_mumbai"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg_northvirginia" {
  provider = aws.northvirginia
  name     = "web_sg_northvirginia"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ===============================
# EC2 INSTANCES
# ===============================

# Mumbai EC2
resource "aws_instance" "ec2_mumbai" {
  provider        = aws.mumbai
  ami             = "ami-03bb6d83c60fc5f7c"  # Ubuntu 22.04 LTS Mumbai
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.mykey_mumbai.key_name
  security_groups = [aws_security_group.web_sg_mumbai.name]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from Nginx - Mumbai</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Mumbai-Nginx"
  }
}

# North Virginia EC2
resource "aws_instance" "ec2_northvirginia" {
  provider        = aws.northvirginia
  ami             = "ami-0ac80df6eff0e70b5"  # Ubuntu 22.04 LTS North Virginia
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.mykey_northvirginia.key_name
  security_groups = [aws_security_group.web_sg_northvirginia.name]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from Nginx - North Virginia</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "NorthVirginia-Nginx"
  }
}

# ===============================
# OUTPUTS
# ===============================
output "mumbai_public_ip" {
  value = aws_instance.ec2_mumbai.public_ip
}

output "northvirginia_public_ip" {
  value = aws_instance.ec2_northvirginia.public_ip
}
