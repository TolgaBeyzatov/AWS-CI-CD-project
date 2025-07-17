resource "aws_db_subnet_group" "vprofile-rds-subgrp" {
  name       = "vprofile-rds-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

  tags = {
    Name = "Subnet group for RDS"
  }
}

resource "aws_elasticache_subnet_group" "vprofile-ecache-subgrp" {
  name       = "vprofile-ecache-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

  tags = {
    Name = "Subnet group for Elasticache"
  }
}

resource "aws_db_instance" "vprofile-rds" {
  identifier             = "vprofile-rds"
  allocated_storage      = 20
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0" //change engine version
  instance_class         = "db.t3.micro"
  db_name                = var.dbname
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = "default.mysql8.0"
  multi_az               = "false"
  publicly_accessible    = "false"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.vprofile-rds-subgrp.name
  vpc_security_group_ids = [aws_security_group.vprofile-backend-sg.id]
}

resource "aws_elasticache_cluster" "vprofile-cache" {
  cluster_id           = "vprofile-cache" //This is the name of the cluster
  engine               = "memcached"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  security_group_ids   = [aws_security_group.vprofile-backend-sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.vprofile-ecache-subgrp.name
}


resource "aws_mq_broker" "vprofile-rmq" {
  broker_name                = "vprofile-rmq"
  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  host_instance_type         = "mq.t3.micro"
  auto_minor_version_upgrade = true
  security_groups            = [aws_security_group.vprofile-backend-sg.id]
  subnet_ids                 = [module.vpc.private_subnets[0]]

  user {
    username = var.rmquser
    password = var.rmqpass
  }
}

data "aws_mq_broker" "rabbitmq" {
  broker_name = "vprofile-rmq"
  depends_on = [
    aws_mq_broker.vprofile-rmq
  ]
}

data "aws_db_instance" "RDS_Endpoint" {
  db_instance_identifier = "vprofile-rds"
  depends_on = [
    aws_db_instance.vprofile-rds
  ]
}

data "aws_elasticache_cluster" "MemcachedEndpoint" {
  cluster_id = "vprofile-cache"
  depends_on = [  
    aws_elasticache_cluster.vprofile-cache
  ]
}

# Outputs the MQ Endpint in a parameter store
resource "aws_ssm_parameter" "MQ_endpoint" {
  name        = "RabbitMQEndpoint"
  description = "Stores the RabbitMQ endpoint"
  type        = "String"
  value       = data.aws_mq_broker.rabbitmq.id
}

# Outputs the RDS Endpoint in a parameter store. 
resource "aws_ssm_parameter" "RDS_endpoint" {
  name        = "RDSEndpoint"
  description = "Stores the RDS endpoint"
  type        = "String"
  value       = data.aws_db_instance.RDS_Endpoint.endpoint
}

# Outputs the Memcached Endpoint in a Parameter store.
resource "aws_ssm_parameter" "Memcached_endpoint" {
  name        = "MemcachedEndpoint"
  description = "Stores the Memcached endpoint"
  type        = "String"
  value       = data.aws_elasticache_cluster.MemcachedEndpoint.configuration_endpoint

}