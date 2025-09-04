resource "aws_ecr_repository" "repo" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = merge(local.common_tags, { Name = var.name })
}

output "ecr_repo_url" {
  value       = aws_ecr_repository.repo.repository_url
  description = "ECR repository URL"
}
