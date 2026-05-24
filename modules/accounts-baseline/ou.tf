resource "aws_organizations_organizational_unit" "shared" {
  name      = "shared"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "nonprod" {
  name      = "nonprod"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "prod"
  parent_id = aws_organizations_organization.org.roots[0].id
}
