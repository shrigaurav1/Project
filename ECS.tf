provider "aws" {
    region = "us-west-2"
}

# ECS CLUSTER

resource "aws_ecs_cluster" "this" {
  name = "ECS_Cluster"
}

# CLOUDWATCH LOG GROUP

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/fargate-task"
  retention_in_days = 3
}

# ECS SERVICE

resource "aws_ecs_service" "this" {
  name            = "ECS_Service_NGINX"
  cluster         = aws_ecs_cluster.this.id
  
  task_definition = "arn:aws:ecs:us-west-2:977873000571:task-definition/fargate-task:1"
  desired_count   = 2
  launch_type     = "FARGATE"

  enable_execute_command = true

  network_configuration {
    subnets         = ["subnet-089f6b05f419311a7","subnet-011626f862159b2ec"]
    security_groups = ["sg-011cf48936c0bcdb0"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:977873000571:targetgroup/ecs-fargate-tg/c769904edf63715c"
    container_name   = "app"
    container_port   = 80
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
}

# AUTO SCALING (2 → 4 tasks)

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_scale_up" {
  name               = "cpu-scale-up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
