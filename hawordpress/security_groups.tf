resource "aws_security_group" "efs" {
    name_prefix = "efs"
    vpc_id      = aws_vpc.hawordpress.id

    ingress {
      from_port = 0
      to_port   = 0
      protocol  = -1
  
      cidr_blocks = [
        "10.0.0.0/16", 
      ]
    }
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = -1
  
        cidr_blocks = [
            "193.30.244.98/32"
        ]
    }
  #   ingress {
  #     from_port = 0
  #     to_port   = 0
  #     protocol  = -1
  
  #     cidr_blocks = [
  #         "0.0.0.0/0"
  #     ]
  # }
    egress {
      from_port = 0
      to_port   = 0
      protocol  = -1
  
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
}

resource "aws_security_group" "alb" {
    name_prefix = "alb"
    vpc_id      = aws_vpc.hawordpress.id

    ingress {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
  
      cidr_blocks = [
        "10.0.0.0/16", 
      ]
    }
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
  
        cidr_blocks = [
            "193.30.244.98/32"
        ]
    }
    ingress {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
  
      cidr_blocks = [
        "10.0.0.0/16", 
      ]
    }
    ingress {
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
  
        cidr_blocks = [
            "193.30.244.98/32"
        ]
    }
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = -1
  
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
    egress {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
  
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
  egress {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
  
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
}

resource "aws_security_group" "asg" {
    name_prefix = "asg"
    vpc_id      = aws_vpc.hawordpress.id

    ingress {
      from_port = 0
      to_port   = 0
      protocol  = -1
  
      cidr_blocks = [
        "10.0.0.0/16", 
      ]
    }
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = -1
  
        cidr_blocks = [
            "193.30.244.98/32"
        ]
    }
    ingress {
      from_port = 0
      to_port   = 0
      protocol  = -1
  
      cidr_blocks = [
          "0.0.0.0/0"
      ]
    }

    egress {
      from_port = 0
      to_port   = 0
      protocol  = -1
  
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
}

resource "aws_security_group" "rds" {
    name_prefix = "rds"
    vpc_id      = aws_vpc.hawordpress.id
    ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
  
      cidr_blocks = [
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.5.0/24",
        "10.0.6.0/24"  
      ]
    }
    egress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
  
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  
}

resource "aws_security_group" "elasticsearch_sg" {
  vpc_id = aws_vpc.hawordpress.id
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 9200
    protocol = "tcp"
    to_port = 9300
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="elasticsearch_sg"
  }
}

resource "aws_security_group" "logstash_sg" {
  vpc_id = aws_vpc.hawordpress.id
    ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 5044
    protocol = "tcp"
    to_port = 5044
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="logstash_sg"
  }
}

resource "aws_security_group" "kibana_sg" {
  vpc_id = aws_vpc.hawordpress.id
    ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 5601
    protocol = "tcp"
    to_port = 5601
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="kibana_sg"
  }
}

resource "aws_security_group" "filebeat_sg" {
  vpc_id = aws_vpc.hawordpress.id
    ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="filebeat_sg"
  }
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.hawordpress.id
    ingress {
    description = "ingress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  egress {
    description = "egress rules"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags={
    Name="bastion_sg"
  }
}
