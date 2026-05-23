output "repository_urls" {
  description = "Urls de connexion pour chaque depot ECR cree"
  value       = { for k, v in aws_ecr_repository.repo : k => v.repository_url }
}

output "repository_arns" {
  description = "ARNs des depots ECR crees"
  value       = { for k, v in aws_ecr_repository.repo : k => v.arn }
}
