# Create an Application Load Balancer (ALB)
provider "aws" {
    region = "us-west-2"
}

resource "aws_lb" "ecs_alb" {
  name               = "ecs-fargate-alb"
  internal           = false # Set to true for internal ALB
  load_balancer_type = "application"
  subnets            = ["subnet-0c5a82504f4edf254", "subnet-02dfac21a35f68e39"]
  security_groups    = ["sg-0699da602dfed0552"] # Attach ALB security group

  tags = {
    Name = "ecs-fargate-alb"
  }
}

# Create a Target Group for ECS Fargate with target_type = "ip"
resource "aws_lb_target_group" "ecs_fargate_tg" {
  name        = "ecs-fargate-tg"
  port        = 80 # Or your application's port
  protocol    = "HTTP"
  vpc_id      = "vpc-02df15041ae6c516d"
  target_type = "ip" # Crucial for ECS Fargate

  health_check {
    path                = "/" # Or your application's health check path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ecs-fargate-target-group"
  }
}

# Create an ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_fargate_tg.arn
  }
}