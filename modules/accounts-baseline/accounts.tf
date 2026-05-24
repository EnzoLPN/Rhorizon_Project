resource "aws_organizations_account" "shared_services" {
  name      = "shared-services"
  email     = var.shared_services_email
  parent_id = aws_organizations_organizational_unit.shared.id
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_account" "nonprod" {
  name      = "nonprod"
  email     = var.nonprod_email
  parent_id = aws_organizations_organizational_unit.nonprod.id
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_account" "prod" {
  name      = "prod"
  email     = var.prod_email
  parent_id = aws_organizations_organizational_unit.prod.id
  role_name = "OrganizationAccountAccessRole"
}
