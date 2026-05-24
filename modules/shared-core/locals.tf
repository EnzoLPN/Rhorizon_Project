locals {
  cross_account_principals = compact([
    var.nonprod_account_id != "" ? "arn:aws:iam::${var.nonprod_account_id}:root" : "",
    var.prod_account_id != "" ? "arn:aws:iam::${var.prod_account_id}:root" : ""
  ])
  has_cross_account = length(local.cross_account_principals) > 0
}
