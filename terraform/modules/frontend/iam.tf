resource "aws_iam_role" "ecs_task_execution_role" {
    name = "fe-app-ecs-role"
    
    assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
}
EOF
}
resource "aws_iam_role" "ecs_task_role" {
  name = "fe-app-ecs-task"
 
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
}
EOF
}

resource "aws_iam_policy" "ecr_access" {
    name = "${var.env_name}-ecr-access-policy"
    policy = jsonencode({
        
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
    })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
    role        = "${aws_iam_role.ecs_task_execution_role.name}"
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_s3" {
    role        = "${aws_iam_role.ecs_task_role.name}"
    policy_arn  = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
