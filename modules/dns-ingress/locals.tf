locals {
  zone_id = var.create_public_zone ? aws_route53_zone.public[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}
