# container_registry.tf

resource "aws_ecr_repository" "blog_repo" {
  name = "pro-blog-repo" # The name of our container repository

  image_tag_mutability = "MUTABLE" # Allows us to overwrite tags like "latest"

  image_scanning_configuration {
    scan_on_push = true # Automatically scan our image for vulnerabilities
  }
}

output "ecr_repository_url" {
  description = "The URL of our new ECR repository"
  value       = aws_ecr_repository.blog_repo.repository_url
}