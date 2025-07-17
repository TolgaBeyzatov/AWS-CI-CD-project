resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "vprofile-task-exec-role-policy"
  path        = "/"
  description = "Allow ECS to retrieve images and add to logs"
  policy      = file("./templates/task-execution-role-policy.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "vprofile-task-execution-role"
  assume_role_policy = file("./templates/task-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_iam_role" "app_task" {
  name               = "vprofile-app-task"
  assume_role_policy = file("./templates/task-assume-role-policy.json")
}

resource "aws_iam_policy" "task_ssm_policy" {
  name        = "vprofile-task-ssm-role-policy"
  path        = "/"
  description = "Policy to allow System Manager to execute in container"
  policy      = file("./templates/task-ssm-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_ssm_policy" {
  role       = aws_iam_role.app_task.name
  policy_arn = aws_iam_policy.task_ssm_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" { // creates log group in cloudwatch for the running containers. Debugging purpose.
  name = "vprofile-api"
}

resource "aws_ecs_cluster" "cluster_vpro" {
  name = "ecs-vprofile"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_ecs_task_definition" "vproapptd" {
  family                   = "vproapp-tdef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_task.arn

  container_definitions = jsonencode([
    {
      name      = "vproapp"
      image     = "${local.account_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/actapp:latest"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      log_configuration = {
        log_driver = "awslogs"
        options = {
          awslogs-create-group  = true
          awslogs-group         = "/ecs/vroapp-act-tdefp"
          awslogs-region        = "${var.AWS_REGION}"
          awslogs-stream-prefix = "ecs"
        }
      }
      # environment = [
      #   {
      #     name  = "ENDPOINT"
      #     value = data.aws_db_instance.RDS_Endpoint.endpoint
      #   },
      #   {
      #     name = "dbuser"
      #     value = var.dbuser
      #   },
      #   {
      #     name = "dbpass"
      #     value = var.dbpass
      #   }

      # {
      #   name  = "MemcachedEndpoint"
      #   value = aws_elasticache_cluster.vprofile-cache.configuration_endpoint

      # },
      # {
      #   name  = "RabbitMQEndpoint"
      #   value = aws_mq_broker.vprofile-rmq.instances.0.endpoints
      # }

    }

  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = {
    Environment = "Name"
    Project     = "vproapp-act-tdef"
  }
}

resource "aws_ecs_service" "vproapp_ecs_service" {
  name                   = "vproapp_ecs_service"
  cluster                = aws_ecs_cluster.cluster_vpro.name
  task_definition        = aws_ecs_task_definition.vproapptd.family
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "vproapp"
    container_port   = 8080
  }

  network_configuration {
    assign_public_ip = false

    subnets = [
      module.vpc.private_subnets[0],
      module.vpc.private_subnets[1],
      module.vpc.private_subnets[2]
    ]

    security_groups = [aws_security_group.allow_access_ecs_service.id]
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

}