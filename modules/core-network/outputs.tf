output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID du VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "Bloc CIDR du VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Liste des IDs des sous-reseaux publics"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Liste des IDs des sous-reseaux privatifs (applicatifs)"
}

output "data_subnet_ids" {
  value       = aws_subnet.data[*].id
  description = "Liste des IDs des sous-reseaux de donnees (RDS)"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "ID du Security Group de l'ALB public"
}

output "app_security_group_id" {
  value       = aws_security_group.app.id
  description = "ID du Security Group du tier applicatif (EKS)"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "ID du Security Group de la base de donnees RDS"
}

output "private_hosted_zone_id" {
  value       = try(aws_route53_zone.private[0].zone_id, null)
  description = "ID de la zone DNS privee Route 53"
}
