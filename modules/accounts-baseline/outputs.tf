output "organization_id" {
  value       = aws_organizations_organization.org.id
  description = "ID de l'organisation AWS"
}

output "organization_root_id" {
  value       = aws_organizations_organization.org.roots[0].id
  description = "ID de la racine (root) de l'organisation"
}

output "ou_shared_id" {
  value       = aws_organizations_organizational_unit.shared.id
  description = "ID de l'OU Shared"
}

output "ou_nonprod_id" {
  value       = aws_organizations_organizational_unit.nonprod.id
  description = "ID de l'OU Non-Prod"
}

output "ou_prod_id" {
  value       = aws_organizations_organizational_unit.prod.id
  description = "ID de l'OU Prod"
}

output "account_shared_services_id" {
  value       = aws_organizations_account.shared_services.id
  description = "ID du compte shared-services"
}

output "account_nonprod_id" {
  value       = aws_organizations_account.nonprod.id
  description = "ID du compte nonprod"
}

output "account_prod_id" {
  value       = aws_organizations_account.prod.id
  description = "ID du compte prod"
}
