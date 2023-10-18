
resource "aws_iam_user_login_profile" "DB_user" {
  count                   = length(var.username)
  user                    = aws_iam_user.eks_user[count.index].name
  password_reset_required = true
  pgp_key                 = "keybase:kenmak"
}

resource "aws_iam_user" "eks_user" {
  count         = length(var.username)
  name          = element(var.username, count.index)
  force_destroy = true

  tags = {
    Department = "eks-user"
  }
}

resource "aws_iam_group" "eks_developer" {
  count = length(var.groups)
  name = element(var.groups, count.index)
}

resource "aws_iam_group_policy" "developer_policy" {
  name   = "developer"
  group  = aws_iam_group.eks_developer[0].name
  policy = data.aws_iam_policy_document.developer.json
  depends_on = [aws_iam_group.eks_developer]
}
resource "aws_iam_group_membership" "db_team" {
  name  = "dev-group-membership"
  users = [aws_iam_user.eks_user[0].name]
  group = aws_iam_group.eks_developer[0].name
}
resource "aws_iam_group_policy" "admins_policy" {
  name   = "admins"
  group  = aws_iam_group.eks_developer[1].name
  policy = data.aws_iam_policy_document.master_role.json
}
resource "aws_iam_group_membership" "admin_team" {
  name  = "admin-group-membership"
  users = [aws_iam_user.eks_user[1].name]
  group = aws_iam_group.eks_developer[1].name
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_role" "managers" {
  name               = "Manager-eks-Role"
  assume_role_policy = data.aws_iam_policy_document.manager_assume_role.json
}


resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.managers.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_policy" "eks_admin" {
  name   = "eks-admin"
  policy = data.aws_iam_policy_document.admin.json
}
data "aws_iam_users" "users" {}
output "users" {
  value = data.aws_iam_users.users.arns
}
