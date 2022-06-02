resource "aws_efs_file_system" "efs" {
   creation_token = "efs1"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 }

data "aws_availability_zones" "available" {}

resource "aws_efs_mount_target" "efs-mt" {
   count = length(module.vpc.azs)
   file_system_id  = "${aws_efs_file_system.efs.id}"
   subnet_id = module.vpc.private_subnets[count.index]
   security_groups = [aws_security_group.efs.id]
 }
 