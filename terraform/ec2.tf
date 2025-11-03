# ec2.tf

# 1. Create a Security Group for our single server
resource "aws_security_group" "app_sg" {
  name        = "pro-blog-app-sg"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.blog_vpc.id

  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443 # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Create the IAM Role for our EC2 instance
# This lets it read secrets and pull from ECR
resource "aws_iam_role" "ec2_instance_role" {
  name = "pro-blog-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Attach policies to the role
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  # This policy lets the instance pull from our container registry
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "secrets_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  # This policy lets the instance read our two secrets
  policy_arn = aws_iam_policy.secret_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "pro-blog-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

#  Allows CodeDeploy to find and manage this instance
resource "aws_iam_role_policy_attachment" "codedeploy_ec2" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

# Allows the AWS Systems Manager (SSM) agent to work,
# which is how CodeDeploy communicates.
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. Create the EC2 Instance
resource "aws_instance" "blog_server" {
  # Ubuntu 22.04 LTS in us-east-1
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t3.micro" # Free Tier

  # Put it in our public subnet
  subnet_id = aws_subnet.app_subnet_1.id

  # Assign our firewall
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Assign our SSH key
  key_name = aws_key_pair.blog_key.key_name

  # Assign the IAM Role
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "Pro-Blog-Server"
  }
}

# 5. We still need the policy from our old ecs.tf file
#    (You can cut and paste this from ecs.tf before you delete it)
resource "aws_iam_policy" "secret_read_policy" {
  name        = "ecs-secret-read-policy"
  description = "Allows EC2 tasks to read specific app secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.secret_key.arn,
          aws_secretsmanager_secret.database_url.arn
        ]
      }
    ]
  })
}