resource "aws_instance" "bastion" {
  ami                         = "ami-065deacbcaac64cf2"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.hawordpress-public-eu-central-1a.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.elastic_ssh_key.key_name
  tags = {
    Name = "bastion"
  }
}