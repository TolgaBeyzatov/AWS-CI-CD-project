

resource "aws_security_group" "vprofile-bastion-sg" {
  name        = "vprofile-bastion-sg"
  description = "Security group for bastionisioner ec2 instance"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name      = "vprofile-bastion-sg"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sshFromMyIPForBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "vprofile-backend-sg" {
  name        = "vprofile-backend-sg"
  description = "Security group for RDS, active mq, elastic cache"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name      = "vprofile-backend-sg"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}


resource "aws_vpc_security_group_ingress_rule" "Allow3306FromBastionInstance" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-bastion-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forBackend" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forBackend" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "Backendsec_group_allow_itself" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-backend-sg.id
  from_port                    = 0
  ip_protocol                  = "tcp"
  to_port                      = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allowInboundTrafficFromECS" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.allow_access_ecs_service.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306


  tags = {
    Name = "ecs-db-security-group"
  }
}

resource "aws_security_group" "allow_access_ecs_service" {
  description = "Access rules for the ECS service"
  name        = "vprofile-ecs-service"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name      = "vprofile-ecs-sg"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }

  # Outbound access to endpoints
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # RDS connectivity
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  # http connectivity 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Application load balancer - INBOUND
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application load balancer - OUTBOUND
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
