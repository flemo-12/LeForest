resource "aws_ecs_task_definition" "fe-app-task-definition" {
    family                   = "fe-app"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 256
    memory                   = 512
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = jsonencode([
        {
        name  = "fe-test-container"
        image = "public.ecr.aws/z9u9y5c7/leforest/frontend:latest"
        cpu : 256
        memory = 256
        portMappings = [
            {
            containerPort = 80
            protocol      = "tcp"
            hostPort      = 80
            }
        ]
        }
  ])
}

resource "aws_security_group" "fe-task-security-group-01" {
  name   = "fe-task-security-group-01"
  vpc_id = aws_vpc.fe_vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [aws_security_group.fe-lb-security-group-01.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "fe-ecs_service" {
  name              = "leforest-fe"
  cluster           = aws_ecs_cluster.fe-cluster.id
  task_definition   = aws_ecs_task_definition.fe-app-task-definition.arn
  launch_type       = "FARGATE"
  desired_count     = 1

  network_configuration {
    security_groups = [aws_security_group.fe-task-security-group-01.id]
    subnets = [aws_subnet.fe_sub1.id, aws_subnet.fe_sub2.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.fe-target-group-01.id
    container_name   = "fe-test-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.fe-lb-lis-01]

}

resource "aws_ecs_cluster" "fe-cluster" {
  name = "fe-cluster"
}

resource "aws_security_group" "fe-lb-security-group-01" {
  name   = "fe-lb-security-group-01"
  vpc_id = aws_vpc.fe_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "fe-lb-01" {
  name            = "fe-lb-01"
  subnets         = [aws_subnet.fe_sub1.id, aws_subnet.fe_sub2.id]
  security_groups = [aws_security_group.fe-lb-security-group-01.id]
}

resource "aws_lb_target_group" "fe-target-group-01" {
  name        = "fe-target-group-01"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fe_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "fe-lb-lis-01" {
  load_balancer_arn = aws_lb.fe-lb-01.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.fe-target-group-01.id
    type             = "forward"
  }
}

output "load_balancer_ip" {
  value = aws_lb.fe-lb-01.dns_name
}