# database.tf

# 1. Create a "subnet group" for our database
# This tells RDS which subnets it's allowed to live in.
resource "aws_db_subnet_group" "blog_db_group" {
  name       = "pro-blog-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]

  tags = {
    Name = "pro-blog-db-group"
  }
}

# 2. Create a Security Group (firewall) for the database
# This will ONLY allow traffic from our future app
resource "aws_security_group" "db_sg" {
  name        = "pro-blog-db-sg"
  description = "Allow inbound postgres traffic from app"
  vpc_id      = aws_vpc.blog_vpc.id

  # In a real setup, we would restrict 'ingress' to our app's
  # security group. For now, we'll open it to the VPC.
  ingress {
    from_port   = 5432 # The port for PostgreSQL
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.blog_vpc.cidr_block] # Only allow traffic from inside our VPC
  }

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Create the RDS Database Instance
resource "aws_db_instance" "blog_db" {
  identifier             = "pro-blog-db"
  instance_class         = "db.t3.micro" # Free tier eligible
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  username               = "db_admin"
  password               = var.db_password # In real projects, use Secrets Manager or SSM Parameter Store
  db_name                = "pro_blog_db" # Initial database name
  db_subnet_group_name   = aws_db_subnet_group.blog_db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # IMPORTANT: This makes the DB private (no public IP)
  publicly_accessible = false 

  # For a project, we can disable backups to save money
  backup_retention_period = 0
  skip_final_snapshot     = true
}