
provider "aws" {
    region = "us-west-2"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "fargate-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

task_role_arn      = "arn:aws:iam::977873000571:role/Ecstaskrole"
execution_role_arn = "arn:aws:iam::977873000571:role/Ecstaskrole"

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "977873000571.dkr.ecr.us-west-2.amazonaws.com/nginx/images:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/fargate-task"
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

 # enable_execute_command = true
}
