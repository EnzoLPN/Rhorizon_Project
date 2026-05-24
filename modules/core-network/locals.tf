locals {
  vpc_mask = tonumber(split("/", var.vpc_cidr)[1])
  newbits  = var.subnet_cidr_mask - local.vpc_mask
  az_names = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  nat_count = var.nat_strategy == "single" ? 1 : var.az_count
}
