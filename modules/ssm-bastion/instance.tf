# Instance EC2 Bastion
resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.al2023.id
  instance_type        = "t3.nano"
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  associate_public_ip_address = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-ssm-bastion"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
