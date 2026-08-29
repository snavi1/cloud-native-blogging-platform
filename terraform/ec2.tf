data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  tags = {
    Name    = "${var.project_name}-bastion"
    Role    = "bastion"
    Project = var.project_name
  }
}

resource "aws_instance" "application" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.application.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  tags = {
    Name    = "${var.project_name}-application"
    Role    = "application"
    Project = var.project_name
  }
}

resource "aws_instance" "database" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.database.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  tags = {
    Name    = "${var.project_name}-database"
    Role    = "database"
    Project = var.project_name
  }
}
