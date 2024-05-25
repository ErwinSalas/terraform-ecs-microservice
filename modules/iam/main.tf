# In AWS, roles are used to grant permissions to entities like services, users, 
# or resources. When an ECS task needs to interact with other AWS services or resources, 
# it often assumes a role to acquire the necessary permissions. 
# the process of assuming roles by ECS tasks (or any AWS service) is managed automatically within AWS.   
# Here's why ECS tasks may need to assume roles:
# Access to AWS Services: 
######### ECS tasks may need to access other AWS services like S3, DynamoDB, or SNS. To do this securely, 
######### they assume a role that has the required permissions to access these services.
# Fine-Grained Permissions: 
######### IAM roles allow you to grant fine-grained permissions. Instead of giving broad permissions to the ECS task's IAM user directly,
######### you can create a role with specific permissions and have the task assume that role, reducing the risk of over-permissioning.
# Temporary Credentials: 
######### When a task assumes a role, it receives temporary credentials. These credentials have a limited lifespan, 
######### improving security by reducing the risk of long-term credential exposure.
# Service-to-Service 
######### Communication: Some AWS services require specific permissions to communicate with each other. 
######### By assuming roles with the appropriate permissions, ECS tasks can facilitate secure service-to-service 
######### communication within the AWS ecosystem.
# Least Privilege Principle: 
######### Following the principle of least privilege, tasks assume roles with only the permissions they need for their specific tasks.
######### This minimizes the potential impact of a compromised task.

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = lower("${var.app_name}-ecs-task-execution-role")
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}