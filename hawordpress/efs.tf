resource "aws_efs_file_system" "efs" {
   creation_token = "efs1"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 }

data "aws_availability_zones" "available" {}

resource "aws_efs_mount_target" "efs-mt1" {
   file_system_id  = "${aws_efs_file_system.efs.id}"
   subnet_id = aws_subnet.hawordpress-private-eu-central-1a.id
   security_groups = [aws_security_group.efs.id]
 }
 
 resource "aws_efs_mount_target" "efs-mt2" {
   file_system_id  = "${aws_efs_file_system.efs.id}"
   subnet_id = aws_subnet.hawordpress-private-eu-central-1b.id
   security_groups = [aws_security_group.efs.id]
 }