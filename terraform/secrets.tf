# secrets.tf

# 1. Generate a random password to use as our Flask SECRET_KEY
resource "random_password" "flask_secret_key" {
  length  = 32
  special = true
}

# 2. Store that random key in AWS Secrets Manager
resource "aws_secretsmanager_secret" "secret_key" {
  name = "pro-blog/secret-key-v3"
}

resource "aws_secretsmanager_secret_version" "secret_key_version" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = random_password.flask_secret_key.result
}

# 3. Store our fully-formed DATABASE_URL in AWS Secrets Manager
resource "aws_secretsmanager_secret" "database_url" {
  name = "pro-blog/database-url-v3"
}

resource "aws_secretsmanager_secret_version" "database_url_version" {
  secret_id = aws_secretsmanager_secret.database_url.id
  
  # This builds our URL from our other resources:
  # "postgresql://USERNAME:PASSWORD@HOST:PORT/DB_NAME"
  secret_string = format(
    "postgresql://%s:%s@%s/%s",
    aws_db_instance.blog_db.username,
    var.db_password,
    aws_db_instance.blog_db.endpoint,
    aws_db_instance.blog_db.db_name
  )
  
  # This makes sure the secret is only created *after* the DB exists
  depends_on = [aws_db_instance.blog_db]
}